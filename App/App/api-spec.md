# Supabase Edge Functions API Documentation

This document provides curl command examples for all Supabase edge functions in both local and production environments.

## Environment Setup

### Local Development
```bash
# Get your local anon key
supabase status
# Look for "anon key" in the output

# Local base URL
LOCAL_URL="http://localhost:54321/functions/v1"
LOCAL_ANON_KEY="your-local-anon-key"
```

### Production
```bash
# Production base URL
PROD_URL="https://bgnymsxduwfrauidowxx.supabase.co/functions/v1"
PROD_ANON_KEY="your-production-anon-key"
```

## API Endpoints

### 1. Add Article
Ingests a new article with metadata extraction and embedding generation.

**Request Body:**
- `language_code` (string, required): Language code (e.g., "en", "ko", "ja")
- `article` (object, required):
  - `url` (string, required): Article URL
  - `title` (string, optional): Article title
  - `description` (string, optional): Article description
  - `source` (string, optional): Article source

**Local:**
```bash
curl -X POST "$LOCAL_URL/add-article" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "language_code": "en",
    "article": {
      "url": "https://example.com/article",
      "title": "Optional Title",
      "description": "Optional description",
      "source": "Example Source"
    }
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/add-article" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "language_code": "en",
    "article": {
      "url": "https://example.com/article",
      "title": "Optional Title",
      "description": "Optional description",
      "source": "Example Source"
    }
  }'
```

**Response:**
```json
{
  "id": 123,
  "url": "https://example.com/article",
  "title": "Extracted title",
  "embedding": [0.1, 0.2, ...],
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Error Responses:**
- `409 Conflict`: Article with the same URL already exists
- `400 Bad Request`: Invalid request format or missing required fields

---

### 2. Add Article to Thread
Adds an article to a specific thread or creates a new thread if needed.

**Request Body:**
- `articleId` (number, required): ID of the article to add
- `threadId` (number, optional): ID of the thread to add to
- `createNewIfNeeded` (boolean, optional, default: true): Create new thread if no match found

**Local:**
```bash
curl -X POST "$LOCAL_URL/add-article-to-thread" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "articleId": 123,
    "threadId": 456,
    "createNewIfNeeded": true
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/add-article-to-thread" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "articleId": 123,
    "threadId": 456,
    "createNewIfNeeded": true
  }'
```

**Response:**
```json
{
  "threadId": 456,
  "created": false,
  "message": "Article successfully added to thread"
}
```

**Error Responses:**
- `404 Not Found`: Article not found
- `400 Bad Request`: Article missing embedding when creating new thread

---

### 3. Article to Thread
Automatically assigns an article to the most similar thread based on embeddings.

**Request Body:**
- `articleId` (number, required): ID of the article to process

**Local:**
```bash
curl -X POST "$LOCAL_URL/article-to-thread" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "articleId": 123
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/article-to-thread" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "articleId": 123
  }'
```

**Response:**
```json
{
  "threadId": 456,
  "message": "Article successfully processed and assigned to thread"
}
```

**Error Responses:**
- `404 Not Found`: Article not found
- `400 Bad Request`: Article missing embedding

---

### 4. Chat Completion
Generates chat completions using OpenAI API.

**Request Body:**
- `systemPrompt` (string, required): System prompt for the AI
- `userText` (string, required): User input text
- `model` (string, optional): Model to use (default: "gpt-4.1-mini")
  - Available models: "gpt-4.1", "gpt-4.1-mini", "gpt-4.1-nano", "gpt-4o"
- `temperature` (number, optional): Temperature setting (default: 0.7)
- `maxTokens` (number, optional): Maximum tokens (default: 4096)

**Local:**
```bash
curl -X POST "$LOCAL_URL/chat-completion" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "systemPrompt": "You are a helpful assistant.",
    "userText": "Explain quantum computing in simple terms."
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/chat-completion" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "systemPrompt": "You are a helpful assistant.",
    "userText": "Explain quantum computing in simple terms."
  }'
```

**Response:**
```json
{
  "message": "AI generated response",
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 50,
    "total_tokens": 150
  },
  "model": "gpt-4"
}
```

**Error Responses:**
- `500 Internal Server Error`: Missing OpenAI API key or API error

---

### 5. Fetch Google Trends
Fetches trending topics from Google Trends RSS feed.

**Query Parameters:**
- `geo` (string, optional, default: "US"): Geographic region code (e.g., "US", "KR", "JP")

**Local:**
```bash
# Default region (US)
curl -X GET "$LOCAL_URL/fetch-google-trends" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY"

# Specific region (Korea)
curl -X GET "$LOCAL_URL/fetch-google-trends?geo=KR" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY"
```

**Production:**
```bash
# Default region (US)
curl -X GET "$PROD_URL/fetch-google-trends" \
  -H "Authorization: Bearer $PROD_ANON_KEY"

# Specific region (Korea)
curl -X GET "$PROD_URL/fetch-google-trends?geo=KR" \
  -H "Authorization: Bearer $PROD_ANON_KEY"
```

**Response:**
```json
{
  "trends": [
    {
      "keyword": "Trending Topic",
      "articles": [
        "https://example.com/article1",
        "https://example.com/article2"
      ]
    }
  ]
}
```

---

### 6. Find Similar Threads
Finds threads similar to a given article based on vector embeddings.

**Request Body:**
- `articleId` (number, required): ID of the article to find similar threads for
- `limit` (number, optional, default: 3): Maximum number of results

**Local:**
```bash
curl -X POST "$LOCAL_URL/find-similar-threads" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "articleId": 123,
    "limit": 5
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/find-similar-threads" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "articleId": 123,
    "limit": 5
  }'
```

**Response:**
```json
{
  "threads": [
    {
      "id": 456,
      "title": "Thread Title",
      "similarity": 0.95,
      "article_ids": [123, 124, 125],
      "main_subject": "Technology",
      "images": ["image1.jpg", "image2.jpg"],
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "count": 1
}
```

---

### 7. Generate Embedding
Generates vector embeddings for text using OpenAI's embedding model.

**Request Body:**
- `text` (string, required): Text to generate embedding for
- `model` (string, optional): Model to use (default: "text-embedding-3-small")
  - Available models: "text-embedding-3-small", "text-embedding-3-large", "text-embedding-ada-002"
  - Recommended: "text-embedding-3-small" (best cost/performance balance)

**Local:**
```bash
curl -X POST "$LOCAL_URL/generate-embedding" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "text": "This is a sample text to generate embeddings for."
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/generate-embedding" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "text": "This is a sample text to generate embeddings for."
  }'
```

**Response:**
```json
{
  "embedding": [0.1, 0.2, 0.3, ...],
  "model": "text-embedding-3-small"
}
```

---

### 8. System Status
Provides comprehensive system information and configuration details.

**Local:**
```bash
curl -X GET "$LOCAL_URL/system-status" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY"
```

**Production:**
```bash
curl -X GET "$PROD_URL/system-status" \
  -H "Authorization: Bearer $PROD_ANON_KEY"
```

**Response:**
```json
{
  "timestamp": "2025-08-02T05:51:24.772Z",
  "environment": "development",
  "isProduction": false,
  "openai": {
    "chatModel": "gpt-4.1-mini",
    "embeddingModel": "text-embedding-3-small",
    "maxTokens": 4096,
    "temperature": 0.7,
    "apiKeyConfigured": true
  },
  "supabase": {
    "url": "http://localhost:54321",
    "serviceRoleKeyConfigured": true,
    "environment": "development"
  },
  "database": {
    "articlesTable": "articles",
    "threadsTable": "threads",
    "usersTable": "users"
  },
  "embedding": {
    "defaultModel": "text-embedding-3-small",
    "dimensions": 1536
  },
  "limits": {
    "maxArticleTextLength": 100000,
    "maxSummaryLength": 500,
    "maxKeywords": 5,
    "similarityThreshold": 0.7
  },
  "environmentVariables": {
    "SUPABASE_URL": true,
    "SUPABASE_ANON_KEY": true,
    "SUPABASE_SERVICE_ROLE_KEY": true,
    "OPENAI_API_KEY": true,
    "OPENAI_CHAT_MODEL": false,
    "OPENAI_EMBEDDING_MODEL": false
  },
  "runtime": {
    "denoVersion": "1.45.2",
    "v8Version": "12.4.254.20",
    "typescriptVersion": "5.4.5"
  },
  "availableFunctions": [
    "add-article",
    "add-article-to-thread",
    "article-to-thread",
    "chat-completion",
    "fetch-google-trends",
    "find-similar-threads",
    "generate-embedding",
    "system-status",
    "add-comment",
    "get-thread-comments",
    "update-comment",
    "delete-comment"
  ],
  "status": "healthy",
  "message": "All systems operational"
}
```

---

### 9. Add Comment
Adds a new comment to a thread with optional AI generation and mention support.

**Request Body:**
- `threadId` (number, required): ID of the thread to comment on
- `content` (string, optional): Comment content (required if AI generation not requested)
- `userSentiment` (number, optional): User's sentiment score (-1.0 to +1.0)
- `mentions` (object, optional): Explicit mentions
  - `articleIds` (array, optional): Array of article IDs to mention
  - `userIds` (array, optional): Array of user IDs to mention  
  - `commentIds` (array, optional): Array of comment IDs to mention
- `aiGeneration` (object, optional): AI generation options
  - `targetSentiment` (number, optional): Target sentiment for generated comment
  - `context` (string, optional): Additional context for generation
- `languageCode` (string, optional, default: "ko"): Language code for AI generation

**Local:**
```bash
# Manual comment
curl -X POST "$LOCAL_URL/add-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "threadId": 123,
    "content": "This is interesting! #article:456 provides good context.",
    "userSentiment": 0.7,
    "mentions": {
      "articleIds": [456],
      "userIds": ["user-uuid-123"]
    }
  }'

# AI generated comment
curl -X POST "$LOCAL_URL/add-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "threadId": 123,
    "languageCode": "ko",
    "aiGeneration": {
      "targetSentiment": 0.5,
      "context": "Focus on the economic implications"
    },
    "mentions": {
      "articleIds": [456]
    }
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/add-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "threadId": 123,
    "content": "Interesting perspective on this topic.",
    "userSentiment": 0.3
  }'
```

**Response:**
```json
{
  "success": true,
  "comment": {
    "id": "comment-uuid-123",
    "thread_id": 123,
    "user_id": "user-uuid-456",
    "content": "This is interesting! #article:456 provides good context.",
    "user_sentiment": 0.7,
    "ai_sentiment": 0.65,
    "ai_sentiment_confidence": 0.85,
    "is_ai_generated": false,
    "created_at": "2024-01-01T00:00:00Z",
    "mentions": [
      {
        "id": "mention-uuid-789",
        "comment_id": "comment-uuid-123",
        "mention_type": "article",
        "mentioned_id": "456"
      }
    ]
  },
  "sentimentAnalysis": {
    "sentiment": 0.65,
    "confidence": 0.85,
    "reasoning": "Positive sentiment with expressions of interest"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Authentication required
- `404 Not Found`: Thread not found
- `400 Bad Request`: Invalid mentions or missing content

---

### 10. Get Thread Comments
Retrieves comments for a specific thread with pagination and sorting options.

**Request Body:**
- `threadId` (number, required): ID of the thread
- `limit` (number, optional, default: 50): Maximum number of comments to return
- `offset` (number, optional, default: 0): Number of comments to skip
- `sortBy` (string, optional, default: "created_at"): Sort field ("created_at", "ai_sentiment", "user_sentiment")
- `sortOrder` (string, optional, default: "desc"): Sort order ("asc", "desc")

**Local:**
```bash
# Get latest comments
curl -X POST "$LOCAL_URL/get-thread-comments" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "threadId": 123,
    "limit": 20,
    "offset": 0,
    "sortBy": "created_at",
    "sortOrder": "desc"
  }'

# Get comments sorted by sentiment
curl -X POST "$LOCAL_URL/get-thread-comments" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "threadId": 123,
    "sortBy": "ai_sentiment",
    "sortOrder": "desc"
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/get-thread-comments" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "threadId": 123,
    "limit": 10
  }'
```

**Response:**
```json
{
  "comments": [
    {
      "id": "comment-uuid-123",
      "thread_id": 123,
      "user_id": "user-uuid-456",
      "content": "Great article! #article:456 explains it well.",
      "user_sentiment": 0.8,
      "ai_sentiment": 0.75,
      "ai_sentiment_confidence": 0.9,
      "is_ai_generated": false,
      "created_at": "2024-01-01T00:00:00Z",
      "mentions": [
        {
          "id": "mention-uuid-789",
          "comment_id": "comment-uuid-123",
          "mention_type": "article",
          "mentioned_id": "456"
        }
      ]
    }
  ],
  "total": 45,
  "nextOffset": 20
}
```

---

### 11. Update Comment
Updates an existing comment's content, sentiment, or mentions.

**Request Body:**
- `commentId` (string, required): UUID of the comment to update
- `content` (string, optional): New comment content
- `userSentiment` (number, optional): Updated user sentiment (-1.0 to +1.0)
- `mentions` (object, optional): Updated mentions
  - `articleIds` (array, optional): Array of article IDs to mention
  - `userIds` (array, optional): Array of user IDs to mention
  - `commentIds` (array, optional): Array of comment IDs to mention

**Local:**
```bash
curl -X POST "$LOCAL_URL/update-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "commentId": "comment-uuid-123",
    "content": "Updated comment with new insights! #article:789",
    "userSentiment": 0.9,
    "mentions": {
      "articleIds": [789],
      "userIds": ["user-uuid-456"]
    }
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/update-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "commentId": "comment-uuid-123",
    "content": "Updated comment content",
    "userSentiment": 0.5
  }'
```

**Response:**
```json
{
  "success": true,
  "comment": {
    "id": "comment-uuid-123",
    "thread_id": 123,
    "user_id": "user-uuid-456",
    "content": "Updated comment with new insights! #article:789",
    "user_sentiment": 0.9,
    "ai_sentiment": 0.85,
    "ai_sentiment_confidence": 0.92,
    "is_ai_generated": false,
    "updated_at": "2024-01-01T01:00:00Z",
    "mentions": [
      {
        "id": "mention-uuid-new",
        "comment_id": "comment-uuid-123",
        "mention_type": "article",
        "mentioned_id": "789"
      }
    ]
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Authentication required
- `404 Not Found`: Comment not found
- `403 Forbidden`: Can only update own comments
- `400 Bad Request`: Invalid mentions

---

### 12. Delete Comment
Deletes a comment and all its mentions.

**Request Body:**
- `commentId` (string, required): UUID of the comment to delete

**Local:**
```bash
curl -X POST "$LOCAL_URL/delete-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "commentId": "comment-uuid-123"
  }'
```

**Production:**
```bash
curl -X POST "$PROD_URL/delete-comment" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROD_ANON_KEY" \
  -d '{
    "commentId": "comment-uuid-123"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Comment deleted successfully"
}
```

**Error Responses:**
- `401 Unauthorized`: Authentication required
- `404 Not Found`: Comment not found
- `403 Forbidden`: Can only delete own comments

---

## Comment System Features

### Mention Types
Comments support three types of mentions:

1. **Article Mentions**: `#article:123` - Reference specific articles in the thread
2. **User Mentions**: `@user:uuid` - Mention other users 
3. **Comment Mentions**: `#comment:uuid` - Reply to or reference other comments

### Sentiment Analysis
- **User Sentiment**: User-specified sentiment score (-1.0 to +1.0)
- **AI Sentiment**: Automatically analyzed sentiment using OpenAI
- **Confidence Score**: AI's confidence in the sentiment analysis (0.0 to 1.0)

### AI Comment Generation
- Supports multiple languages (ko, en, ja, zh, es, fr, de)
- Uses thread context and mentioned articles for relevance
- Can target specific sentiment ranges
- Includes custom context for specialized generation

### Mention Parsing
- Automatic parsing of mentions from comment content
- Validation of mentioned entities (articles, users, comments must exist)
- Separate storage in `comment_mentions` table for efficient querying

---

## Common Configuration Constants

### Default Values
- `DEFAULT_SIMILARITY_THRESHOLD`: 0.7 (configured via SIMILARITY_THRESHOLD env var)
- `DEFAULT_MAX_SIMILAR_THREADS`: 3
- `DEFAULT_GOOGLE_TREND_REGION`: "KR"

### OpenAI Model Configuration
The system uses environment variables to configure OpenAI models:

**Environment Variables:**
- `OPENAI_CHAT_MODEL`: Chat completion model (default: "gpt-4.1-mini")
- `OPENAI_EMBEDDING_MODEL`: Embedding model (default: "text-embedding-3-small")
- `OPENAI_MAX_TOKENS`: Maximum tokens for chat completion (default: 4096)
- `OPENAI_TEMPERATURE`: Temperature for chat completion (default: 0.7)
- `SIMILARITY_THRESHOLD`: Similarity threshold for thread matching (default: 0.7)

**Available Chat Models (2025):**
- `gpt-4.1`: Latest high-performance model with 1M token context
- `gpt-4.1-mini`: Fast, efficient model (83% cheaper than gpt-4o-mini)
- `gpt-4.1-nano`: Fastest and cheapest model
- `gpt-4o`: Previous generation flagship model

**Available Embedding Models (2025):**
- `text-embedding-3-small`: Recommended (1536 dimensions, $0.00002/1k tokens)
- `text-embedding-3-large`: Best performance (3072 dimensions, $0.00013/1k tokens)
- `text-embedding-ada-002`: Legacy model (1536 dimensions, $0.0001/1k tokens)

**Model Selection Guidelines:**
- For most use cases: Use `gpt-4.1-mini` + `text-embedding-3-small`
- For high performance: Use `gpt-4.1` + `text-embedding-3-large`
- For cost optimization: Use `gpt-4.1-nano` + `text-embedding-3-small`

### Supported Languages
Language is automatically detected based on the `geo` parameter in Google Trends:
- KR → ko (Korean)
- JP → ja (Japanese)
- CN/TW/HK → zh (Chinese)
- DE → de (German)
- FR → fr (French)
- ES/AR/MX → es (Spanish)
- EN/US/GB/CA/AU/IN → en (English)

## Error Response Format
All error responses follow this format:
```json
{
  "error": "Error message",
  "details": {
    "additional": "information"
  }
}
```

## Testing Tips

1. **Get your local anon key:**
   ```bash
   supabase status
   ```

2. **Test with sample data:**
   ```bash
   # Test add-article with a real URL
   curl -X POST "$LOCAL_URL/add-article" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $LOCAL_ANON_KEY" \
     -d '{
       "language_code": "en",
       "article": {
         "url": "https://www.theverge.com/2024/1/1/sample-article"
       }
     }'
   ```

3. **View function logs:**
   ```bash
   supabase functions logs --no-verify
   ```

4. **Check CORS headers (for browser-based requests):**
   All endpoints include proper CORS headers for cross-origin requests.

---

# TypeScript API Documentation

The TypeScript API provides web scraping, content extraction, and batch processing capabilities using Node.js/Express with Playwright for browser automation.

## Environment Setup

### Local Development
```bash
# Base URL
TS_API_URL="http://localhost:3000/api"
TS_API_KEY="5f3afd2448dc99ddcbbc903a67d99ebe"  # Local development key
```

### Production
```bash
# Production base URL (replace with your actual domain)
TS_API_URL="https://your-production-domain.com/api"
TS_API_KEY="your-production-api-key"
```

## TypeScript API Endpoints

### 1. Server Status
Check server health and browser pool status.

**Local:**
```bash
curl -X GET "$TS_API_URL/status" \
  -H "x-api-key: $TS_API_KEY"
```

**Response:**
```json
{
  "success": true,
  "status": {
    "server": "running",
    "browserPool": {
      "totalBrowsers": 5,
      "availableBrowsers": 3,
      "busyBrowsers": 2
    }
  }
}
```

---

### 2. Web Scraping
Scrape web pages with advanced options including smart mode, auto-scroll, and metadata extraction.

**Request Body:**
- `url` (string, required): Target URL to scrape
- `includeHtml` (boolean, optional): Include raw HTML content
- `includeMeta` (boolean, optional): Include meta tags and SEO data
- `includeLinks` (boolean, optional): Extract all links from the page
- `extractHeroImage` (boolean, optional): Extract main image from the page
- `smartMode` (boolean, optional): Use intelligent content detection
- `autoScroll` (boolean, optional): Auto-scroll to load dynamic content
- `waitUntil` (string, optional): Wait condition ("load", "domcontentloaded", "networkidle")
- `maxWaitTime` (number, optional): Maximum wait time in milliseconds (default: 30000)

**Local:**
```bash
curl -X POST "$TS_API_URL/scrape" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $TS_API_KEY" \
  -d '{
    "url": "https://example.com",
    "includeHtml": true,
    "includeMeta": true,
    "includeLinks": true,
    "extractHeroImage": true,
    "smartMode": true,
    "autoScroll": true,
    "waitUntil": "networkidle",
    "maxWaitTime": 30000
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://example.com",
    "title": "Page Title",
    "description": "Page description",
    "content": "Extracted text content",
    "html": "<html>...</html>",
    "meta": {
      "keywords": "keyword1, keyword2",
      "author": "Author Name",
      "publishedTime": "2024-01-01T00:00:00Z"
    },
    "links": ["https://link1.com", "https://link2.com"],
    "heroImage": "https://example.com/image.jpg"
  }
}
```

---

### 3. Reader Mode
Extract readable content from web pages using Mozilla Readability.

**Request Body:**
- `url` (string, required): Target URL to extract readable content from

**Local:**
```bash
curl -X POST "$TS_API_URL/reader-mode" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $TS_API_KEY" \
  -d '{
    "url": "https://example.com/article"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "title": "Article Title",
    "content": "Clean, readable article content",
    "textContent": "Plain text version",
    "length": 1234,
    "excerpt": "Article excerpt...",
    "byline": "Author Name",
    "dir": "ltr",
    "siteName": "Example Site",
    "publishedTime": "2024-01-01T00:00:00Z"
  }
}
```

---

### 4. Add Articles (Batch Processing)
Process multiple articles and add them to the system via Supabase functions.

**Request Body:**
- `articles` (array, required): Array of article objects
  - `url` (string, required): Article URL
  - `title` (string, optional): Article title
  - `description` (string, optional): Article description
  - `source` (string, optional): Article source
- `parallel` (boolean, optional, default: false): Process articles in parallel
- `languageCode` (string, optional, default: "en"): Language code for processing

**Sequential Processing (Default):**
```bash
curl -X POST "$TS_API_URL/add-articles" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $TS_API_KEY" \
  -d '{
    "articles": [
      {"url": "https://example.com/article1"},
      {"url": "https://example.com/article2"},
      {"url": "https://example.com/article3"}
    ]
  }'
```

**Parallel Processing:**
```bash
curl -X POST "$TS_API_URL/add-articles" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $TS_API_KEY" \
  -d '{
    "articles": [
      {"url": "https://example.com/article1"},
      {"url": "https://example.com/article2"},
      {"url": "https://example.com/article3"}
    ],
    "parallel": true
  }'
```

**Response:**
```json
{
  "success": true,
  "jobId": "job_123456789",
  "message": "Articles processing started",
  "articleCount": 3,
  "processingMode": "sequential"
}
```

---

### 5. Job Status
Check the status of batch processing jobs.

**Path Parameters:**
- `jobId` (string, required): Job ID returned from add-articles endpoint

**Local:**
```bash
curl -X GET "$TS_API_URL/jobs/job_123456789/status" \
  -H "x-api-key: $TS_API_KEY"
```

**Response (In Progress):**
```json
{
  "success": true,
  "job": {
    "id": "job_123456789",
    "status": "processing",
    "progress": {
      "completed": 2,
      "total": 3,
      "percentage": 67
    },
    "results": [
      {
        "url": "https://example.com/article1",
        "status": "success",
        "articleId": 123
      },
      {
        "url": "https://example.com/article2",
        "status": "success",
        "articleId": 124
      },
      {
        "url": "https://example.com/article3",
        "status": "processing"
      }
    ],
    "startedAt": "2024-01-01T00:00:00Z"
  }
}
```

**Response (Completed):**
```json
{
  "success": true,
  "job": {
    "id": "job_123456789",
    "status": "completed",
    "progress": {
      "completed": 3,
      "total": 3,
      "percentage": 100
    },
    "results": [
      {
        "url": "https://example.com/article1",
        "status": "success",
        "articleId": 123
      },
      {
        "url": "https://example.com/article2",
        "status": "success",
        "articleId": 124
      },
      {
        "url": "https://example.com/article3",
        "status": "error",
        "error": "Failed to extract content"
      }
    ],
    "startedAt": "2024-01-01T00:00:00Z",
    "completedAt": "2024-01-01T00:01:30Z"
  }
}
```

---

## TypeScript API Configuration

### Authentication
All TypeScript API endpoints require authentication via the `x-api-key` header.

### Browser Pool
- The TypeScript API maintains a pool of Playwright browsers for efficient scraping
- Default pool size: 5 browsers
- Browsers are automatically managed and reused for optimal performance

### Processing Modes
- **Sequential**: Articles processed one by one (default, more reliable)
- **Parallel**: Articles processed simultaneously (faster, but more resource-intensive)

### Error Handling
All TypeScript API endpoints return consistent error responses:
```json
{
  "success": false,
  "error": "Error message",
  "details": {
    "code": "ERROR_CODE",
    "additional": "information"
  }
}
```

---

## Combined Workflow Example

Here's how to use both APIs together for a complete article processing workflow:

```bash
# 1. Use TypeScript API to scrape and extract content
curl -X POST "$TS_API_URL/add-articles" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $TS_API_KEY" \
  -d '{
    "articles": [
      {"url": "https://news.example.com/article1"},
      {"url": "https://tech.example.com/article2"}
    ],
    "parallel": false
  }'

# 2. Monitor job progress
curl -X GET "$TS_API_URL/jobs/JOB_ID/status" \
  -H "x-api-key: $TS_API_KEY"

# 3. Once articles are processed, use Supabase functions for analysis
curl -X POST "$LOCAL_URL/find-similar-threads" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOCAL_ANON_KEY" \
  -d '{
    "articleId": 123
  }'
```

## Authentication Notes
- **Supabase Functions**: All endpoints except `fetch-google-trends` require authentication via Bearer token
- **TypeScript API**: All endpoints require authentication via `x-api-key` header
- Use the anon key for Supabase local development
- Use the production anon key for Supabase production requests
- The TypeScript API uses a separate API key system for authentication
