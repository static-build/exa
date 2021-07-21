
prepare(){
    if [ -d code ]; then
        echo "Already exists"
        git subtree pull --prefix code https://github.com/ogham/exa.git master --squash
    else
        git subtree add --prefix code https://github.com/ogham/exa.git master --squash
    fi
}

appname=exa

# apt-get install mingw-w64
# apt install gcc

build_win(){
    (
        cd code
        cross build --target x86_64-pc-windows-gnu --release
    )
    cp code/target/x86_64-pc-windows-gnu/release/${appname}.exe bin/${appname}.x64.exe
    (
        cd bin
        xrc 7z
        _7z a ${appname}.x64.exe.7z ${appname}.x64.exe
        rm ${appname}.x64.exe
    )
}

build_main(){

    local rust_target=${1:?rust_target}
    local target_name=${2:?binary}
    local exe=${3:-${appname}}

    echo "Building $rust_target with $target_name"

    [ -f "bin/$target_name.7z" ] && return 0

    (
        cd code && {
            cross build --target "$rust_target" --release
        }
    ) && {
        cp "code/target/$rust_target/release/$exe" "bin/$target_name" && (
            cd bin && {
                xrc 7z
                _7z a "$target_name.7z" "$target_name"
                rm "$target_name"
            }
        )
    }
}

build_linux_x64(){
    build_main x86_64-unknown-linux-musl ${appname}.linux.x64
}

build_linux_arm64(){
    build_main aarch64-unknown-linux-musl ${appname}.linux.arm64
}

build_linux_armv7hf(){
    build_main armv7-unknown-linux-musleabihf ${appname}.linux.armv7hf
}

build_linux_armv7(){
    build_main armv7-unknown-linux-musleabi ${appname}.linux.armv7
}

main(){
    build_linux_x64
    build_linux_arm64
    # build_linux_armv7
    build_linux_armv7hf

    build_main aarch64-apple-darwin ${appname}.darwin.arm64
    build_main x86_64-apple-darwin ${appname}.darwin.x64

    build_main x86_64-pc-windows-gnu ${appname}.x64.exe ${appname}.exe
}

