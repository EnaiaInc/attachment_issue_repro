#!/bin/bash
# create_draft_incremental.sh
source .env

# Verify environment variables
if [[ -z "$NYLAS_API_KEY" || -z "$NYLAS_GRANT_ID" || -z "$TO_EMAIL" ]]; then
  echo "Missing environment variables. Ensure NYLAS_API_KEY, NYLAS_GRANT_ID, and TO_EMAIL are set in .env."
  exit 1
fi

# Define initial message payload - all on one line to avoid formatting issues
INITIAL_PAYLOAD='{"subject":"Test attachments - Added after draft creation (incorrect headers)","body":"<html><body>Initial draft creation with no attachments yet.</body></html>","to":[{"email":"'$TO_EMAIL'"}]}'

# Create initial draft
echo "Creating draft..."
DRAFT_RESPONSE=$(curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: application/json" \
  -d "$INITIAL_PAYLOAD")

# Extract and verify draft ID
DRAFT_ID=$(echo $DRAFT_RESPONSE | jq -r '.data.id')
if [[ "$DRAFT_ID" == "null" || -z "$DRAFT_ID" ]]; then
  echo "Failed to create draft. Response: $DRAFT_RESPONSE"
  exit 1
fi
echo "Created draft with ID: $DRAFT_ID"

# Define update payload with attachment references - all on one line
UPDATE_PAYLOAD='{"subject":"Test attachments - Added after draft creation (incorrect headers)","body":"<html><body>This email was created first, then attachments were added via PATCH.<br><br>There appears to be a bug in this approach:<br>- The inline image below will have Content-Disposition: inline (correct)<br>- The PDF attachment will also have Content-Disposition: inline (incorrect - should be '\''attachment'\'')<br><br>Most email clients will still render this correctly, but check the email source to verify the incorrect headers.<br><br><img src='\''cid:hali.png'\''><br>And here is a PDF attachment</body></html>","to":[{"email":"'$TO_EMAIL'"}]}'

# Update draft with attachments
echo "Updating draft to add attachments..."
curl --request PATCH \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: multipart/form-data" \
  --form "message=$UPDATE_PAYLOAD" \
  --form "hali.png=@files/hali.png" \
  --form "toaster_oven=@files/toaster oven.pdf" | jq

# Get draft to show attachment status
echo "Getting draft to show attachment status..."
curl -s -X GET \
  "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $NYLAS_API_KEY" | jq

# Send the draft
echo "Sending draft..."
curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "Content-Type: application/json" | jq