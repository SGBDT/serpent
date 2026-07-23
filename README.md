# Orochi

A rhythm game for the original Game Boy.

## Entering the Development Environment

### Linux with Nix Flake

To enter the development environment:

1. Install the [Nix](https://nixos.org/download/#download-nix) package manager.

2. Add the following line to your per-user Nix configuration at `~/.config/nix/nix.conf` to enable flakes:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

3. Enter the Nix development at the project root:

```bash
nix develop
```

#### Building and Running in the Nix Environment

To build the program in the Nix environment, first stage all files you want to build. Then, run the command:

```bash
nix build
```

To run the program using Gearboy after building:

```bash
nix run
```

### Windows with WSL (Ubuntu)

To install all the necessary tools for the development environment, follow the instructions:

1. Enter the Windows Subsystem for Linux (WSL) Ubuntu shell:

```powershell
wsl
```

2. Install [GNU Make](https://www.gnu.org/software/make):

```bash
sudo apt install make
```

3. Install [GBDK](https://gbdk.org) to your home directory:

```bash
cd ~
wget https://github.com/gbdk-2020/gbdk-2020/releases/latest/download/gbdk-linux64.tar.gz
tar -xzf gbdk-linux64.tar.gz
```

4. Install [Gearboy](https://github.com/drhelius/ppa-geardome) from the Ubuntu PPA with the official instructions.

5. After adding the PPA, run:

```bash
sudo apt update
sudo apt install gearboy
```

6. Install [Game Boy Tile Designer (GBTD)](https://www.devrs.com/gb/hmgd/gbtd.html) and [Game Boy Map Builder (GBMB)](https://www.devrs.com/gb/hmgd/gbmb.html).

7. Change your directory back into the project root.

8. Create `./scripts/.wslmake.sh` with the following Bash script:

```bash
export GBDK_HOME=$HOME/gbdk
make $1
```

9. Exit and restart WSL from the project directory:

```powershell
wsl --shutdown
wsl
```

#### Building and Running with WSl

To build the program with GNU Make, run:

```bash
./scripts/.wslmake.sh
```

To run the program using Gearboy, use:

```bash
./scripts/.wslmake.sh run
```
