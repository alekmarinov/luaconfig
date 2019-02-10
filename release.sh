#!/bin/bash

if git status | grep "nothing to commit, working tree clean" > /dev/null ; then
    VERSION=$(git describe)

    VERSION=(${VERSION//[\.\-]/ })
    V1=${VERSION[0]}
    V2=${VERSION[1]}
    V3=${VERSION[2]}
    V4=${VERSION[3]}

    # increment release
    release_type=$1
    if [ "$release_type" == "major" ]; then
        V1=$((V1+1))
        V2=0
        V3=0
    elif [ "$release_type" == "minor" ]; then
        V2=$((V2+1))
        V3=0
    else
        V3=$((V3+1))
    fi

    VERSION="$V1.$V2.$V3"
    echo "Releasing version $VERSION"
    rm -f luaconfig-*.rockspec
    sed "s/version[[:space:]]*=.*/version = \"$VERSION-0\"/" rockspec > luaconfig-$VERSION-0.rockspec
    sed -i "s/tag[[:space:]]*=.*/tag = \"$VERSION\"/" luaconfig-$VERSION-0.rockspec
    git add luaconfig-$VERSION-0.rockspec
    git commit -a -m "Version incremented to $VERSION"
    git tag -a $VERSION -m "Tagged version $VERSION"
    git log -10 --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
    git push --tags
    git push
else
    echo "You can't release with modified or untracked files since the last commit!"
    echo "The command 'git status' must not show any modified or untracked files."
    exit 1
fi
