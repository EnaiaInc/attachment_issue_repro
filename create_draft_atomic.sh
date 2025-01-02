#!/bin/bash

source .env

if [[ -z "$NYLAS_API_KEY" || -z "$NYLAS_GRANT_ID" || -z "$TO_EMAIL" ]]; then
  echo "Missing environment variables. Ensure NYLAS_API_KEY, NYLAS_GRANT_ID, and TO_EMAIL are set in .env."
  exit 1
fi

# First create draft with both attachments
echo "Creating draft..."
DRAFT_RESPONSE=$(curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: multipart/form-data" \
  --form "message={
    \"subject\": \"Test inline vs regular attachments\",
    \"body\": \"<html><body>Testing inline vs regular attachments<br><img src='cid:hali.png'><br>And here is a PDF</body></html>\",
    \"to\": [{
      \"email\": \"$TO_EMAIL\"
    }]
  }" \
  --form "hali.png=@hali.png" \
  --form "toaster_oven=@toaster oven.pdf")

# Extract draft ID from response
DRAFT_ID=$(echo $DRAFT_RESPONSE | jq -r '.data.id')
if [[ "$DRAFT_ID" == "null" ]]; then
  echo "Failed to create draft. Response: $DRAFT_RESPONSE"
  exit 1
fi
echo "Created draft with ID: $DRAFT_ID"

# Get the draft to show how Nylas marks both as inline
echo "Getting draft to show attachment status..."
curl -s -X GET \
  "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $NYLAS_API_KEY" | jq

# Send the draft
echo "Sending draft..."
SEND_RESPONSE=$(curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "Content-Type: application/json")

echo "Send response: $SEND_RESPONSE"