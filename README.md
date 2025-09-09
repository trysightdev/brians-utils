# brians-utils
General purpose stuff.

```bash
sudo apt update
sudo apt install -y ca-certificates curl wget gnupg
sudo mkdir -p /etc/apt/keyrings

# Add GitHub CLI GPG key and apt source
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update
sudo apt install -y gh
gh --version

sudo apt install jq

gh auth login

gh repo list TrySight-Inc --limit 200 --json name --jq '.[].name'

./copy_ruleset_with_dest.sh InputBridge

```
