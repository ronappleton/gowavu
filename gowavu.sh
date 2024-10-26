#!/bin/bash

# Script Name: gowavu
# Description: A script to set up Go, Node.js, pnpm, and Wails for building cross-platform desktop applications.
# Author: Ron Appleton

set -e

# Function to display help message
function show_help {
    echo "Usage: gowavu [command] [options]"
    echo
    echo "Commands:"
    echo "  setup       Setup Go, Node.js, pnpm, and Wails."
    echo "  new <name>  Create a new Wails project."
    echo "  build       Build the application for all platforms."
    echo "  update      Check for script updates."
    echo "  help        Display this help message."
    echo
}

# Function to check if running as root
function check_root {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root for setup tasks. Please run with sudo."
        exit 1
    fi
}

# Function to check if a command exists
function command_exists {
    command -v "$1" &> /dev/null
}

# Function to check for script updates
function check_for_updates {
    local script_path="/usr/local/bin/gowavu"
    local latest_version=$(curl -s https://api.github.com/repos/ronappleton/gowavu/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    local current_version=$(grep -Po '"tag_name": "\K.*?(?=")' <<< $(curl -s https://api.github.com/repos/ronappleton/gowavu/releases/tags/$(basename $(dirname $(realpath $0)))))

    if [[ "$latest_version" != "$current_version" ]]; then
        echo "A new version ($latest_version) is available. Updating..."
        wget -q https://github.com/ronappleton/gowavu/releases/download/$latest_version/gowavu.sh -O $script_path
        chmod +x $script_path
        echo "Script updated to version $latest_version. Please re-run your command."
        exit 0
    else
        echo "You are using the latest version ($current_version)."
    fi
}

# Move the script to /usr/local/bin if not already there
function move_script {
    if [[ ! $(realpath "$0") == "/usr/local/bin/gowavu" ]]; then
        echo "Moving script to /usr/local/bin..."
        sudo mv "$0" /usr/local/bin/gowavu
        if [[ $? -ne 0 ]]; then
            echo "Failed to move the script. Please check permissions."
            exit 1
        fi
        sudo chmod +x /usr/local/bin/gowavu
        echo "Script moved successfully. Re-running setup..."
        exec /usr/local/bin/gowavu setup
    fi
}

# Function to check Go installation
function go_check {
    desired_version=${1:-1.21.1}
    if command_exists go; then
        installed_version=$(go version | awk '{print $3}' | sed 's/go//')
        if [[ "$installed_version" == "$desired_version" ]]; then
            echo "Go version $installed_version is already installed."
            return 0
        else
            echo "Go version $installed_version is installed, but version $desired_version is required."
            return 1
        fi
    else
        echo "Go is not installed."
        return 1
    fi
}

# Function to install Go
if ! declare -f install_go > /dev/null; then
    function install_go {
        read -p "Enter the Go version you want to install (default: 1.21.1): " go_version
        go_version=${go_version:-1.21.1}
        echo "Installing Go version $go_version..."
        wget "https://golang.org/dl/go${go_version}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        export PATH=$PATH:/usr/local/go/bin
        echo "Go $go_version installed successfully."
    }
fi

# Function to install Node.js
if ! declare -f install_node > /dev/null; then
    function install_node {
        echo "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
        sudo apt-get install -y nodejs
        echo "Node.js installed successfully."
    }
fi

# Function to install pnpm
if ! declare -f install_pnpm > /dev/null; then
    function install_pnpm {
        echo "Installing pnpm..."
        npm install -g pnpm
        pnpm setup
        echo "pnpm installed successfully."
    }
fi

# Function to install Wails
if ! declare -f install_wails > /dev/null; then
    function install_wails {
        echo "Installing Wails..."
        go install github.com/wailsapp/wails/v2/cmd/wails@latest
        echo "Wails installed successfully."
    }
fi

# Function to setup GOPATH
if ! declare -f setup_gopath > /dev/null; then
    function setup_gopath {
        if [[ -z "$GOPATH" ]]; then
            read -p "Enter the GOPATH you want to set (default: $HOME/go): " gopath
            gopath=${gopath:-$HOME/go}
            mkdir -p "$gopath"
            echo "export GOPATH=$gopath" >> ~/.bashrc
            echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
            echo "GOPATH set to $gopath."
        fi
    }
fi

# Function to create a new Wails project
if ! declare -f create_project > /dev/null; then
    function create_project {
        if [[ -z "$1" ]]; then
            echo "Please provide a project name."
            return 1
        fi

        project_name=$1
        echo "Creating a new Wails project with Vue and TypeScript..."
        wails init -n "$project_name" -t vue

        # Open the project in GoLand
        if command_exists goland; then
            goland "$project_name" &
        else
            echo "GoLand not found. Please open the project manually."
        fi
    }
fi

# Function to build the application for all platforms
if ! declare -f build_app > /dev/null; then
    function build_app {
        echo "Building the application for all platforms..."
        wails build
    }
fi

# Main script execution
echo "Starting gowavu script..."
case "$1" in
    setup)
        echo "Running setup..."
        check_root
        read -p "Enter the Go version you want to install (default: 1.21.1): " go_version
        go_version=${go_version:-1.21.1}

        if go_check "$go_version"; then
            echo "Go is already installed."
        else
            install_go "$go_version"
        fi

        if command_exists node; then
            echo "Node.js is already installed."
        else
            install_node
        fi

        if command_exists pnpm; then
            echo "pnpm is already installed."
            pnpm setup
        else
            install_pnpm
        fi

        if ! command_exists wails; then
            install_wails
        else
            echo "Wails is already installed."
        fi

        setup_gopath
        echo "Setup completed successfully."
        ;;
    new)
        echo "Creating new project..."
        if command_exists wails; then
            create_project "$2"
        else
            echo "Wails is not installed. Please run 'gowavu setup' first."
        fi
        ;;
    build)
        echo "Building application..."
        if command_exists wails; then
            build_app
        else
            echo "Wails is not installed. Please run 'gowavu setup' first."
        fi
        ;;
    update)
        echo "Checking for updates..."
        check_root
        check_for_updates
        ;;
    help)
        show_help
        ;;
    *)
        show_help
        ;;
esac