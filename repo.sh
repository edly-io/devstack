#!/usr/bin/env bash

set -e
set -o pipefail

# Script for Git repos housing edX services. These repos are mounted as
# data volumes into their corresponding Docker containers to facilitate development.
# Repos are cloned to/removed from the directory above the one housing this file.

if [ -z "$DEVSTACK_WORKSPACE" ]; then
    echo "need to set workspace dir"
    exit 1
elif [ -d "$DEVSTACK_WORKSPACE" ]; then
    cd $DEVSTACK_WORKSPACE
else
    echo "Workspace directory $DEVSTACK_WORKSPACE doesn't exist"
    exit 1
fi

repos=(
    "https://github.com/edx/course-discovery.git"
    "https://github.com/edx/credentials.git"
    "https://github.com/edx/cs_comments_service.git"
    "https://github.com/edx/ecommerce.git"
    "https://github.com/edx/edx-e2e-tests.git"
    "https://github.com/edx/edx-notes-api.git"
    "https://github.com/edx/edx-platform.git"
    "https://github.com/edx/xqueue.git"
    "https://github.com/edx/edx-analytics-pipeline.git"
)

private_repos=(
    # Needed to run whitelabel tests.
    "https://github.com/edx/edx-themes.git"
)

wp_plugin_repos=(
    "git@github.com:edly-io/edly-wp-plugin.git"
)

wp_theme_repos=(
    "git@github.com:edly-io/edly-wp-theme.git"
)

name_pattern=".*/(.*).git"
eldy_repo_pattern=".*edly-io/(.*).git"


_checkout ()
{
    repos_to_checkout=("$@")

    if [ -z "$OPENEDX_RELEASE" ]; then
        branch="master"
    else
        branch="open-release/${OPENEDX_RELEASE}"
    fi
    for repo in "${repos_to_checkout[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been cloned.
        if [ -d "$name" -a -n "$(ls -A "$name" 2>/dev/null)" ]; then
            cd $name
            echo "Checking out branch $branch of $name"
            git pull
            git checkout "$branch"
            cd ..
        fi
    done
}

checkout ()
{
    _checkout "${repos[@]}"
}

_clone ()
{
    # for repo in ${repos[*]}
    repos_to_clone=("$@")

    for repo in "${repos_to_clone[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been checked out.
        if [ -d "$name" -a -n "$(ls -A "$name" 2>/dev/null)" ]; then
            printf "The [%s] repo is already checked out. Continuing.\n" $name
        else
            if [ "${SHALLOW_CLONE}" == "1" ]; then
                git clone --depth=1 $repo
            else
                git clone $repo
            fi
            if [ -n "${OPENEDX_RELEASE}" ]; then
                cd $name
                git checkout open-release/${OPENEDX_RELEASE}
                cd ..
            fi
        fi
    done
    cd - &> /dev/null
}

_checkout_and_update_branch ()
{
    GIT_SYMBOLIC_REF="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH_NAME=${GIT_SYMBOLIC_REF##refs/heads/}
    if [ "${BRANCH_NAME}" == "${OPENEDX_GIT_BRANCH}" ]; then
        git pull origin ${OPENEDX_GIT_BRANCH}
    else
        git fetch origin ${OPENEDX_GIT_BRANCH}:${OPENEDX_GIT_BRANCH}
        git checkout ${OPENEDX_GIT_BRANCH}
    fi
    find . -name '*.pyc' -not -path './.git/*' -delete
}


_get_latest_wp_tag() {
 curl --silent "https://api.github.com/repos/WordPress/WordPress/tags" | # Get latest release from GitHub>
    python -c "import sys, json; print json.load(sys.stdin)[0]['name']"
}

clone ()
{
    _clone "${repos[@]}"

    WP_PLUGIN_DIR=$DEVSTACK_WORKSPACE/wp_plugins
    WP_THEME_DIR=$DEVSTACK_WORKSPACE/wp_themes

    [ -d $WP_PLUGIN_DIR ] || mkdir $WP_PLUGIN_DIR
    [ -d $WP_THEME_DIR ] || mkdir $WP_THEME_DIR

    # clone WP plugins
    cd $WP_PLUGIN_DIR
    for repo in "${wp_plugin_repos[@]}"
    do
        [[ $repo =~ $eldy_repo_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ ! -d $name ]; then
          git clone $repo --branch develop
        else
          printf "The [%s] repo is already checked out. \n" $repo
        fi
    done

    # clone themes
    cd $WP_THEME_DIR
    for repo in "${wp_theme_repos[@]}"
    do
        [[ $repo =~ $eldy_repo_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ ! -d $name ]; then
          git clone $repo --branch develop
        else
          printf "The [%s] repo is already checked out. \n" $repo
        fi
    done

    cd $DEVSTACK_WORKSPACE/devstack &> /dev/null
}

clone_private ()
{
    _clone "${private_repos[@]}"
}

reset ()
{
    currDir=$(pwd)
    for repo in ${repos[*]}
    do
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ -d "$name" ]; then
            cd $name;git reset --hard HEAD;git checkout master;git reset --hard origin/master;git pull;cd "$currDir"
        else
            printf "The [%s] repo is not cloned. Continuing.\n" $name
        fi
    done
    cd - &> /dev/null
}

status ()
{
    currDir=$(pwd)
    for repo in ${repos[*]}
    do
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ -d "$name" ]; then
            printf "\nGit status for [%s]:\n" $name
            cd $name;git status;cd "$currDir"
        else
            printf "The [%s] repo is not cloned. Continuing.\n" $name
        fi
    done
    cd - &> /dev/null
}

if [ "$1" == "checkout" ]; then
    checkout
elif [ "$1" == "clone" ]; then
    clone
elif [ "$1" == "whitelabel" ]; then
    clone_private
elif [ "$1" == "reset" ]; then
    read -p "This will override any uncommited changes in your local git checkouts. Would you like to proceed? [y/n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reset
    fi
elif [ "$1" == "status" ]; then
    status
fi
