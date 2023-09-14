#!/bin/sh

#
#  Get ready for local port configuration for vite.
#
#  This script does:
#  1. Install 'dotenv-cli' package with pnpm
#  2. Add 'PORT=' to \`.env.local\` file (create one if it doesn't exist)
#  3. Only if the \`package.json\` file has "scripts.dev" field as "vite dev",
#    1. Create a copy of package.json as \`package.json.setup-pnpm-vite-port-env\`
#       which changes the line into the following:
#
#       `"dotenv -c -- bash -c 'npx vite dev --port ${PORT:-5173}'"`
#
#       Note the original package.json is not changed.
#
#  4. Guide user
#
#  The user is left with a new `package.json.setup-pnpm-vite-port-env` and `.env.local` file.
#
#
#
#"dev": "vite dev",
#
#"dev": "dotenv -c -- bash -c 'npx vite dev --port ${PORT:-5173}'",
#
#cat package.json | jq '.scripts.dev="dotenv -c -- bash -c '\''npx vite dev --port ${PORT:-5173}'\''"' 

# 1. install dotenv-cli
pnpm add -D dotenv-cli

# 2. add a .env.local file
echo "PORT=" >> .env.local
## check if the file is already ignored in git. if not, add to gitignore
git check-ignore .env.local > /dev/null
if [ $? -ne 0 ]; then
  echo '.env.local' >> .gitignore
fi

# 3. create temp package file with modified dev script
cat package.json | npx jq 'if .scripts.dev == "vite dev" then .scripts.dev="dotenv -c -- bash -c '\''npx vite dev --port ${PORT:-5173}'\''" else . end' > package.json.setup-pnpm-vite-port-env
diff --color --ignore-all-space package.json package.json.setup-pnpm-vite-port-env

# 4. Guide user
cat <<EOF
  
  Preparation complete. You now have:

  1. dotenv-cli package installed as a dev dependency
  2. \`.env.local\` file with empty "PORT="
  3. \`package.json.setup-pnpm-vite-port-env\` file with modified "dev" script.

  You should fill in the PORT var in \`.env.local\`, and change the package file, and you are good to go.
  Happy coding! 😎

EOF

