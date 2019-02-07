#!/bin/sh

if git status | grep "nothing to commit, working tree clean" > /dev/null; then
    VERSION=`git describe`

    # parse git version
    VSHA=${VERSION/[^-]*\-/}
    V1=${VERSION/\.[0-9]*/}
    V3=${VERSION/[0-9]*\./}
    V2=${V3/-*/}
    V3=${V3#$V2-}
    V3=${V3/-*/}

    # increment release
    release_type=$1
    if [ "$release_type" == "major" ]; then
        V1=$((V1+1))
    elif [ "$release_type" == "minor" ]; then
        V2=$((V2+1))
    else
        V3=$((V3+1))
    fi

    VERSION="$V1.$V2.$V3"
    sed -i "s/tag[[:space:]]*=.*/tag = \"$VERSION\"/" rockspec
    echo "Releasing version $VERSION"
    git commit -m "Version incremented to $VERSION"
    git tag -a $VERSION -m "Tagged version $VERSION"
    git log -10 --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
    git push --tags
else
    echo "You can't release with modified or untracked files since the last commit!"
    echo "The command 'git status' must not show any modified or untracked files."
    exit 1
fi
