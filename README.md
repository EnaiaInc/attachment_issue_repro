# Nylas Email Attachment Test

This script demonstrates sending emails with both inline and regular attachments using the Nylas API via ExNylas.

## Prerequisites

- Elixir installed
- Nylas account with API credentials
- Required files, included in repo:
  - `hali.png` - An image file for inline attachment
  - `toaster oven.pdf` - A PDF file for regular attachment

## Setup

1. Copy `.env.sample` to `.env`:
   ```bash
   cp .env.sample .env
   ```

2. Fill in your Nylas credentials and recipient email in `.env`:
   - `NYLAS_GRANT_ID`
   - `NYLAS_API_KEY`
   - `NYLAS_CLIENT_ID`
   - `TO_EMAIL`

## Running the Elixir Script

```bash
./test_nylas_attachments.exs
```
