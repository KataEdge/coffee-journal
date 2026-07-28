# AWS S3 Direct Upload via Presigned URL

## Upload Strategy
1. Client requests a Presigned Upload URL from Backend (Supabase Edge Function or AWS Lambda).
2. Client uploads binary image data directly to S3 using HTTP `PUT` request with `Content-Type: image/jpeg` or `image/png`.
3. S3 returns HTTP 200 OK.
4. Client saves the public S3 URL in `tasting_notes.image_urls`.

## Security Best Practices
- Never store AWS Secret Access Key or Secret Credentials on the iOS client app.
- Presigned URLs must have short expiration windows (e.g., 5-15 minutes).
- File key naming convention: `tasting-notes/{user_id}/{UUID}.jpg`.
