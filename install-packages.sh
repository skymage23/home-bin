#!/usr/bin/bash

REPO_GH_CLI_URL="https://cli.github.com/packages/rpm/gh-cli.repo"

declare -A package_list
package_list+=("gh")
package_list+=("git")
package_list+=("neovim")

die(){
    if [ $# -lt 2 ]; then
        >&2 echo "die(): too few arguments"
    elif [ $# -gt 2 ]; then
        >&2 echo "die(): too many arguments"
    fi

    local func_name="${1}"
    local message="${2}"

    >&2 echo "${func_name}: ${message}"
    exit 1
}

redhat_add_repo(){
    local func_name="redhat_add_repo"
    if [ $# -lt 2 ]; then
        die "${func_name}" "too few arguments."
    elif [ $# -gt 2 ]; then
        die "${func_name}" "too many arguments."
    fi

    local repo_id="${1}"
    local repo_url="${2}"

    #I know this is unintuitive, but bash if logic is stupid:
    if  [ "$(echo -n \"$(dnf repolist --enabled repo-spec \\\"${repo_id}\\\" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')\")" != "" ]; then
        echo "${repo_id}: Already enabled"
	return
    fi
    
    local command_stderr
    local dnf_conf="2>>>command_stderr 1>/dev/null  sudo dnf config-manager"
    
    #We could add a check to see if we already have the repo and it is just disabled.
    if test "$(dnf repolist --disabled repo-spec \"${repo_id}\")" != ""; then
        echo "Adding repo: ${repo_id}"
        eval "${dnf_conf} --add-repo --file-repofile \"${repo_url}\""
        if [ $? -ne 0 ]; then
            die "${func_name}" "Error configuring repo: ${command_stderr}" 
        fi
    else
        echo "Repo \"${repo_id}\" exists, but is not enabled."
    fi

    echo "Enabling repo: ${repo_name}"
    eval "${dnf_conf} --set-enabled \"${repo_id}\""
    if [ $? -ne 0 ]; then
        die "${func_name}" "Error enabling repo: ${command_stderr}" 
    fi

    sudo dnf update
}

#fedora_add_repo(){
#    local func_name="fedora_add_repo"
#    if [ $# -lt 2 ]; then
#        die "${func_name}" "too few arguments."
#    elif [ $# -gt 2 ]; then
#        die "${func_name}" "too many arguments."
#    fi
#
#    local repo_id="${1}"
#    local repo_url="${2}"
#
#    dnf repolist --enabled repo-spec "${repo_id}" 2>&1 >/dev/null
#    if [ $? -eq 0 ]; then
#        echo "${repo_id}: Already enabled"
#	return
#    fi
#
#    sudo dnf config-manager add-repo --file-repofile "${REPO_GH_CLI_URL}"
#    sudo dnf config-manager setopd gh-cli.enabled=1
#    sudo dnf update
#}

redhat_add_repo "gh-cli" "https://cli.github.com/packages/repo/gh-cli.repo"
redhat_add_repo "rpmfusion" "file:///home/liveuser/Downloads/rpmfusion-free-release-10.noarch/etc/yum.repos.d/rpmfusion-free-updates.repo"
