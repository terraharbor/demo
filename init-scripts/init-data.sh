#!/bin/bash

# Script to easily initialize users and projects via the backend API.

API_URL="http://localhost:8000"
ADMIN_USERNAME="administrator"
ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/\n" | cut -c1-32)


USER_PASSWORDS=()

# Create administrator user.
echo "Creating administrator user..."
curl -s -X 'POST' "$API_URL/register" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "username=$ADMIN_USERNAME&password=$ADMIN_PASSWORD"
USER_CREDENTIALS["$ADMIN_USERNAME"]="$ADMIN_PASSWORD"
echo
echo "Administrator user created!"
echo

# Create bearer token for administrator user.
echo "Creating bearer token for administrator..."
RESPONSE=$(curl -s -X 'POST' "$API_URL/token" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "username=$ADMIN_USERNAME&password=$ADMIN_PASSWORD")
ADMIN_BEARER_TOKEN=$(echo "$RESPONSE" | jq -r .access_token)
echo
echo "Administrator's token created!"
echo

# Create 8 random users.
USERNAMES=("alice" "bob" "charlie" "david" "eve" "frank" "grace" "heidi")
for USER in "${USERNAMES[@]}"; do
  PASSWORD=$(openssl rand -base64 16 | tr -d "=+/\n" | cut -c1-16)
  echo "Creating user $USER with password $PASSWORD..."
  curl -s -X 'POST' "$API_URL/register" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "username=$USER&password=$PASSWORD"
  echo
  echo "User $USER created!"
  echo
  USER_PASSWORDS+=("$PASSWORD")
done

# Create 2 teams.
echo "Creating team Alpha..."
curl -s -X 'POST' "$API_URL/teams" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Alpha", "description": "The Alpha team." }'
echo
echo "Team Alpha created!"
echo

echo "Creating team Beta..."
curl -s -X 'POST' "$API_URL/teams" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Beta", "description": "The Beta team." }'
echo
echo "Team Beta created!"
echo

# Update team 1 (Alpha) to add all even indexed users.
echo "Updating team Alpha to add all even indexed users..."
EVEN_USER_IDS=()
for i in "${!USERNAMES[@]}"; do
  if (( i % 2 == 0 )); then
    # Assuming user IDs are i+2 (since admin is 1, users start at 2)
    EVEN_USER_IDS+=( $((i+2)) )
  fi
done
USER_IDS_JSON=$(printf ",%s" "${EVEN_USER_IDS[@]}")
USER_IDS_JSON="${USER_IDS_JSON:1}"
curl -s -X 'PATCH' "$API_URL/teams/1" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{ \"name\": \"Alpha\", \"description\": \"The Alpha team.\", \"userIds\": [${USER_IDS_JSON}] }"
echo
echo "Team Alpha updated with even indexed users!"
echo

# Update team 2 (Beta) to add all odd indexed users.
echo "Updating team Beta to add all odd indexed users..."
ODD_USER_IDS=()
for i in "${!USERNAMES[@]}"; do
  if (( i % 2 == 1 )); then
    # Assuming user IDs are i+2 (since admin is 1, users start at 2)
    ODD_USER_IDS+=( $((i+2)) )
  fi
done
USER_IDS_JSON=$(printf ",%s" "${ODD_USER_IDS[@]}")
USER_IDS_JSON="${USER_IDS_JSON:1}"
curl -s -X 'PATCH' "$API_URL/teams/2" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{ \"name\": \"Beta\", \"description\": \"The Beta team.\", \"userIds\": [${USER_IDS_JSON}] }"
echo
echo "Team Beta updated with odd indexed users!"
echo

# Create 3 projects.
echo "Creating project 1..."
curl -s -X 'POST' "$API_URL/projects" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Nullify", "description": "Terraform code to create multiple null_resource." }'
echo
echo "Project 1 created!"
echo

echo "Creating project 2..."
curl -s -X 'POST' "$API_URL/projects" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "TerraHarbor Azure VM Copy", "description": "Copy of the Terraform code that deploys the TerraHarbor Azure VM." }'
echo
echo "Project 2 created!"
echo

echo "Creating project 3..."
curl -s -X 'POST' "$API_URL/projects" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Empty", "description": "Just an empty project for both teams." }'
echo
echo "Project 3 created!"
echo

# Assign projects to teams
echo "Assigning project 1 (Nullify) to team Alpha..."
curl -s -X 'PATCH' "$API_URL/projects/1" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Nullify", "description": "Terraform code to create multiple null_resource.", "teamIds": [1] }'
echo
echo "Project 1 assigned to team Alpha!"
echo

echo "Assigning project 2 (TerraHarbor Azure VM Copy) to team Beta..."
curl -s -X 'PATCH' "$API_URL/projects/2" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "TerraHarbor Azure VM Copy", "description": "Copy of the Terraform code that deploys the TerraHarbor Azure VM.", "teamIds": [2] }'
echo
echo "Project 2 assigned to team Beta!"
echo

echo "Assigning project 3 (Empty) to both teams..."
curl -s -X 'PATCH' "$API_URL/projects/3" \
  -H "Authorization: Bearer $ADMIN_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Empty", "description": "Just an empty project for both teams.", "teamIds": [1,2] }'
echo
echo "Project 3 assigned to both teams!"
echo

echo "Initialization complete."

# Output credentials as JSON.
echo
echo "User credentials JSON output:"
{
  echo "{"
  echo "  \"administrator\": {"
  echo "    \"username\": \"$ADMIN_USERNAME\"," 
  echo "    \"password\": \"$ADMIN_PASSWORD\""
  echo "  },"
  echo "  \"users\": ["
  for i in "${!USERNAMES[@]}"; do
    if [ $i -ne 0 ]; then echo ","; fi
    echo -n "    { \"username\": \"${USERNAMES[$i]}\", \"password\": \"${USER_PASSWORDS[$i]}\" }"
  done
  echo
  echo "  ]"
  echo "}"
} > users_and_admin_credentials.json
cat users_and_admin_credentials.json
echo "Credentials saved to users_and_admin_credentials.json"
