
prepare(){
    if [ -d code ]; then
        echo "Already exists"
        git subtree pull --prefix code https://github.com/ogham/exa.git v0.10.1 --squash
    else
        git subtree add --prefix code https://github.com/ogham/exa.git v0.10.1 --squash
    fi
}

appname=exa

# apt-get install mingw-w64
# apt install gcc

build_main(){

    local rust_target=${1:?rust_target}
    local target_name=${2:?binary}
    local exe=${3:-${appname}}

    echo "Building $rust_target with $target_name"

    [ -f "bin/$target_name.7z" ] && return 0
    [ -f "bin/$target_name.7z.001" ] && return 0

    (
        cd code && {
            cross build --target "$rust_target" --release
        }
    ) && {
        cp "code/target/$rust_target/release/$exe" "bin/$target_name" && (
            cd bin && {
                xrc p7z
                p7z -v970k a "$target_name.7z" "$target_name"
                ls $target_name.7z* | wc -l | tr -cd '0-9' > "$target_name.7z"
                rm "$target_name"
            }
        )
    }
}

main(){
    build_main x86_64-unknown-linux-musl ${appname}.linux.x64

    build_main aarch64-unknown-linux-musl ${appname}.linux.arm64
    # build_main aarch64-unknown-linux-gnu ${appname}.linux.arm64

    # build_main armv7-unknown-linux-musleabi ${appname}.linux.armv7
    build_main armv7-unknown-linux-musleabihf ${appname}.linux.armv7hf

    build_main aarch64-apple-darwin ${appname}.darwin.arm64
    build_main x86_64-apple-darwin ${appname}.darwin.x64

    # build_main x86_64-pc-windows-gnu ${appname}.x64.exe ${appname}.exe
    # build_main aarch64-pc-windows-msvc ${appname}.arm64.exe ${appname}.exe
}



