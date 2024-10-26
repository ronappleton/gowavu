# GoWavu

A script to set up Go, Node.js, pnpm, and Wails for building cross-platform desktop applications.

## Installation

To download and run the script in a one-liner, use the following command:

```sh
curl -s https://raw.githubusercontent.com/ronappleton/gowavu/master/gowavu.sh | sudo bash -s setup
```

## Usage

```sh
gowavu [command] [options]
```

### Commands

- `setup` Setup Go, Node.js, pnpm, and Wails.
- `new <name>`  Create a new Wails project.
- `build`       Build the application for all platforms.
- `update`      Check for script updates.
- `help`        Display this help message.

### Examples

**Setup the environment:**

```sh
gowavu setup
```

**Create a new Wails project:**

```sh
gowavu new myproject
```

**Build the application:**

```sh
gowavu build
```

**Check for updates:**

```sh 
gowavu update
```

**Display help message:**

```sh 
gowavu help
```
