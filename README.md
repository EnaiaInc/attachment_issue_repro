# Nylas Draft Attachment Bug Demo

This repository demonstrates a bug in the Nylas API's handling of attachment Content-Disposition headers when attachments are added to an existing draft.

## Bug Description

When creating a draft email with both inline images and regular attachments:

1. If attachments are included in the initial draft creation (atomic approach), the Content-Disposition headers are set correctly:
   - Inline images get `Content-Disposition: inline`
   - Regular attachments get `Content-Disposition: attachment`

2. If attachments are added to an existing draft (incremental approach), all attachments incorrectly get `Content-Disposition: inline`
   - Both inline images and regular attachments get `Content-Disposition: inline`
   - The PDF should have `Content-Disposition: attachment`

Note: Most email clients will render both approaches correctly despite the incorrect headers in the incremental approach. To verify the bug, you'll need to check the email source.

## Setup

1. Copy the environment file and fill in your values:
   ```bash
   cp .env.sample .env
   ```

2. Fill in all values in .env:
   - NYLAS_GRANT_ID: Your Nylas grant ID
   - NYLAS_API_KEY: Your Nylas API key
   - NYLAS_CLIENT_ID: Your Nylas client ID
   - TO_EMAIL: Email address where you want to receive the test emails

## Running the Tests

1. Run the atomic approach (correct behavior):
   ```bash
   ./create_draft_atomic.sh
   ```

2. Run the incremental approach (buggy behavior):
   ```bash
   ./create_draft_incremental.sh
   ```

3. Check the source of both received emails to verify the Content-Disposition headers.

## Files

- `files/hali.png`: Test inline image
- `files/toaster oven.pdf`: Test PDF attachment
- `create_draft_atomic.sh`: Creates draft with correct headers
- `create_draft_incremental.sh`: Demonstrates the bug
