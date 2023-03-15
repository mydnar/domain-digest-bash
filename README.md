# Domain Digest
Domain Digest is a command-line tool that parses WHOIS and DNS data and prints an overview in a simple-to-read format. This tool is useful for troubleshooting domain and DNS issues, and it gathers important information such as registrar, domain status, NS, A, MX, and TXT records.

## Installation

#### 1. Create a ~/bin directory if it doesn't exist
`[ -d ~/bin ] || mkdir ~/bin`

#### 2. Check if ~/bin is in your user's PATH
`echo $PATH`
  - NOTE: If ~/bin is in your user's PATH, you can skip to step 4 of the installation process.

#### 3. Add ~/bin directory to PATH
 - To add the ~/bin directory to your user's PATH, you can add the following line to your shell configuration file (e.g. .bashrc or .bash_profile):  

  ```export PATH="$HOME/bin:$PATH"```

- After adding the line, you can either open a new terminal window or run `source <path to configuration file>` to apply the changes to your current terminal session.

#### 4. Download the script to the ~/bin directory and make it executable
```
$ curl -o ~/bin/dns.sh https://raw.githubusercontent.com/username/repo/master/dns.sh
$ chmod +x ~/bin/dns.sh
```
## Usage
`$ dns.sh example.com`
