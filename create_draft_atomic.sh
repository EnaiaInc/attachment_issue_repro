#!/bin/bash
# create_draft_atomic.sh
source .env

# Verify environment variables
if [[ -z "$NYLAS_API_KEY" || -z "$NYLAS_GRANT_ID" || -z "$TO_EMAIL" ]]; then
  echo "Missing environment variables. Ensure NYLAS_API_KEY, NYLAS_GRANT_ID, and TO_EMAIL are set in .env."
  exit 1
fi

# Define message payload - all on one line to avoid formatting issues
MESSAGE_PAYLOAD='{"subject":"Test attachments - Added in initial draft creation (correct headers)","body":"<html><body>This email was created with attachments included in the initial draft creation.<br><br>In this approach, both attachment Content-Disposition headers should be correct:<br>- The inline image below should have Content-Disposition: inline (correct)<br>- The PDF attachment should have Content-Disposition: attachment (correct)<br><br>Check the email source to verify the headers are correct.<br><br><img src='\''cid:hali.png'\''><br>And here is a PDF attachment</body></html>","to":[{"email":"'$TO_EMAIL'"}]}'

# Create draft with attachments
echo "Creating draft..."
DRAFT_RESPONSE=$(curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: multipart/form-data" \
  --form "message=$MESSAGE_PAYLOAD" \
  --form "hali.png=@files/hali.png" \
  --form "toaster_oven=@files/toaster oven.pdf")

# Extract and verify draft ID
DRAFT_ID=$(echo $DRAFT_RESPONSE | jq -r '.data.id')
if [[ "$DRAFT_ID" == "null" || -z "$DRAFT_ID" ]]; then
  echo "Failed to create draft. Response: $DRAFT_RESPONSE"
  exit 1
fi
echo "Created draft with ID: $DRAFT_ID"

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