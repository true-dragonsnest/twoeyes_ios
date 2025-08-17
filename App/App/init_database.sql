-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Create article category enum type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'article_category') THEN
        CREATE TYPE article_category AS ENUM (
            'Politics',
            'Economy',
            'Society',
            'International',
            'Culture',
            'Sports',
            'Technology/Science',
            'Life/Health',
            'Environment'
        );
    END IF;
END$$;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT UNIQUE NOT NULL,
    gender TEXT DEFAULT NULL,
    nickname TEXT DEFAULT NULL,
    profile_picture_url TEXT DEFAULT NULL,
    last_comment TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create threads table
CREATE TABLE IF NOT EXISTS threads (
    id SERIAL PRIMARY KEY,
    embedding VECTOR(1536) NOT NULL, -- Assuming OpenAI embedding dimension
    title TEXT DEFAULT NULL,
    main_subject TEXT,
    primary_category article_category,
    article_snapshots JSONB DEFAULT '[]', -- Array of article snapshot objects
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create articles table
CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    url TEXT NOT NULL,
    source TEXT DEFAULT NULL,
    author UUID REFERENCES users(id), -- References custom users table
    title TEXT DEFAULT NULL,
    text TEXT DEFAULT NULL,
    language TEXT DEFAULT NULL,
    image TEXT DEFAULT NULL,
    description TEXT DEFAULT NULL,
    summary TEXT DEFAULT NULL,
    main_subject TEXT DEFAULT NULL,
    embedding VECTOR(1536), -- Vector representation for similarity search
    thread_id INTEGER REFERENCES threads(id) DEFAULT NULL,
    entities TEXT[] DEFAULT '{}', -- Array of high importance entity names
    sentiment FLOAT,
    sentiment_entity_specific JSONB DEFAULT '[]', -- Array of entity-specific sentiment objects
    sentiment_reasoning TEXT DEFAULT NULL,
    primary_category article_category,
    secondary_category TEXT,
    keywords TEXT[] DEFAULT '{}', -- Simple keywords array
    key_points TEXT[] DEFAULT '{}' -- Key points from structured summarization
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_articles_url ON articles(url);
CREATE INDEX IF NOT EXISTS idx_articles_author ON articles(author);
CREATE INDEX IF NOT EXISTS idx_articles_thread_id ON articles(thread_id);
CREATE INDEX IF NOT EXISTS idx_articles_created_at ON articles(created_at);
CREATE INDEX IF NOT EXISTS idx_articles_primary_category ON articles(primary_category);

CREATE INDEX IF NOT EXISTS idx_threads_created_at ON threads(created_at);
CREATE INDEX IF NOT EXISTS idx_threads_primary_category ON threads(primary_category);

CREATE INDEX IF NOT EXISTS idx_users_user_id ON users(user_id);

-- Create vector similarity indexes for embedding search
CREATE INDEX IF NOT EXISTS idx_articles_embedding ON articles USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_threads_embedding ON threads USING ivfflat (embedding vector_cosine_ops);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_articles_updated_at ON articles;
CREATE TRIGGER update_articles_updated_at 
    BEFORE UPDATE ON articles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_threads_updated_at ON threads;
CREATE TRIGGER update_threads_updated_at 
    BEFORE UPDATE ON threads 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON comments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_thread_entities_updated_at ON thread_entities;
CREATE TRIGGER update_thread_entities_updated_at 
    BEFORE UPDATE ON thread_entities 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create thread_entities table for entity aggregation
CREATE TABLE IF NOT EXISTS thread_entities (
    id SERIAL PRIMARY KEY,
    thread_id INTEGER NOT NULL REFERENCES threads(id) ON DELETE CASCADE,
    entity_name TEXT NOT NULL,
    sentiment_sum FLOAT DEFAULT 0,
    sentiment_count INTEGER DEFAULT 0,
    average_sentiment FLOAT GENERATED ALWAYS AS (
        CASE WHEN sentiment_count > 0 
             THEN sentiment_sum / sentiment_count 
             ELSE NULL END
    ) STORED,
    first_seen_at TIMESTAMP DEFAULT NOW(),
    last_updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(thread_id, entity_name)
);

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id INTEGER NOT NULL REFERENCES threads(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    user_nickname TEXT DEFAULT NULL, -- Snapshot of user nickname at comment creation
    user_profile_picture_url TEXT DEFAULT NULL, -- Snapshot of user profile picture at comment creation
    user_sentiment FLOAT DEFAULT NULL, -- -1.0 to +1.0
    ai_sentiment FLOAT DEFAULT NULL, -- -1.0 to +1.0
    ai_sentiment_confidence FLOAT DEFAULT NULL, -- 0.0 to 1.0
    is_ai_generated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create comment_mentions table
CREATE TABLE IF NOT EXISTS comment_mentions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    mention_type TEXT NOT NULL CHECK (mention_type IN ('article', 'user', 'comment')),
    mentioned_id TEXT NOT NULL, -- Can be article ID (integer as text), user ID (UUID as text), or comment ID (UUID as text)
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for comments
CREATE INDEX IF NOT EXISTS idx_comments_thread_id ON comments(thread_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);

-- Create indexes for comment_mentions
CREATE INDEX IF NOT EXISTS idx_comment_mentions_comment_id ON comment_mentions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_mentions_mention_type ON comment_mentions(mention_type);
CREATE INDEX IF NOT EXISTS idx_comment_mentions_mentioned_id ON comment_mentions(mentioned_id);

-- Create indexes for thread_entities
CREATE INDEX IF NOT EXISTS idx_thread_entities_thread_id ON thread_entities(thread_id);
CREATE INDEX IF NOT EXISTS idx_thread_entities_entity_name ON thread_entities(entity_name);
CREATE INDEX IF NOT EXISTS idx_thread_entities_average_sentiment ON thread_entities(average_sentiment);
CREATE INDEX IF NOT EXISTS idx_thread_entities_last_updated_at ON thread_entities(last_updated_at);
CREATE INDEX IF NOT EXISTS idx_thread_entities_entity_sentiment ON thread_entities(entity_name, average_sentiment);

-- Add Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_mentions ENABLE ROW LEVEL SECURITY;
ALTER TABLE thread_entities ENABLE ROW LEVEL SECURITY;

-- Users policies - anyone can view and insert
DROP POLICY IF EXISTS "Anyone can view users" ON users;
CREATE POLICY "Anyone can view users" ON users FOR SELECT USING (true);
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
CREATE POLICY "Anyone can insert users" ON users FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid()::text = user_id);

-- Articles policies - anyone can view and insert
DROP POLICY IF EXISTS "Anyone can view articles" ON articles;
CREATE POLICY "Anyone can view articles" ON articles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Anyone can insert articles" ON articles;
CREATE POLICY "Anyone can insert articles" ON articles FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Users can update own articles" ON articles;
CREATE POLICY "Users can update own articles" ON articles FOR UPDATE USING (auth.uid() = author);
DROP POLICY IF EXISTS "Users can delete own articles" ON articles;
CREATE POLICY "Users can delete own articles" ON articles FOR DELETE USING (auth.uid() = author);

-- Threads policies - anyone can view and insert
DROP POLICY IF EXISTS "Anyone can view threads" ON threads;
CREATE POLICY "Anyone can view threads" ON threads FOR SELECT USING (true);
DROP POLICY IF EXISTS "Anyone can insert threads" ON threads;
CREATE POLICY "Anyone can insert threads" ON threads FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Authenticated users can update threads" ON threads;
CREATE POLICY "Authenticated users can update threads" ON threads FOR UPDATE USING (auth.role() = 'authenticated');

-- Comments policies
DROP POLICY IF EXISTS "Anyone can view comments" ON comments;
CREATE POLICY "Anyone can view comments" ON comments FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can insert comments" ON comments;
CREATE POLICY "Authenticated users can insert comments" ON comments FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
DROP POLICY IF EXISTS "Users can update own comments" ON comments;
CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own comments" ON comments;
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);

-- Comment mentions policies
DROP POLICY IF EXISTS "Anyone can view comment mentions" ON comment_mentions;
CREATE POLICY "Anyone can view comment mentions" ON comment_mentions FOR SELECT USING (true);
DROP POLICY IF EXISTS "Comment owner can insert mentions" ON comment_mentions;
CREATE POLICY "Comment owner can insert mentions" ON comment_mentions FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM comments 
        WHERE comments.id = comment_mentions.comment_id 
        AND comments.user_id = auth.uid()
    )
);
DROP POLICY IF EXISTS "Comment owner can delete mentions" ON comment_mentions;
CREATE POLICY "Comment owner can delete mentions" ON comment_mentions FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM comments 
        WHERE comments.id = comment_mentions.comment_id 
        AND comments.user_id = auth.uid()
    )
);

-- Thread entities policies - anyone can view, system can manage
DROP POLICY IF EXISTS "Anyone can view thread entities" ON thread_entities;
CREATE POLICY "Anyone can view thread entities" ON thread_entities FOR SELECT USING (true);
DROP POLICY IF EXISTS "System can insert thread entities" ON thread_entities;
CREATE POLICY "System can insert thread entities" ON thread_entities FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "System can update thread entities" ON thread_entities;
CREATE POLICY "System can update thread entities" ON thread_entities FOR UPDATE USING (true);
DROP POLICY IF EXISTS "System can delete thread entities" ON thread_entities;
CREATE POLICY "System can delete thread entities" ON thread_entities FOR DELETE USING (true);

-- Create RPC functions for thread similarity search and management

-- Function to find similar threads using vector similarity
CREATE OR REPLACE FUNCTION find_similar_threads(
    query_embedding vector(1536),
    similarity_threshold float DEFAULT 0.7,
    limit_count int DEFAULT 5
)
RETURNS TABLE(
    id int,
    title text,
    similarity float,
    main_subject text,
    article_snapshots jsonb,
    created_at timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        1 - (t.embedding <=> query_embedding) AS similarity,
        t.main_subject,
        t.article_snapshots,
        t.created_at
    FROM threads t
    WHERE 
        1 - (t.embedding <=> query_embedding) >= similarity_threshold
    ORDER BY similarity DESC
    LIMIT limit_count;
END;
$$;


-- Function to update thread embedding based on all articles in the thread
CREATE OR REPLACE FUNCTION update_thread_embedding(thread_id_param int)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    avg_embedding vector(1536);
BEGIN
    -- Calculate average embedding from all articles in the thread
    SELECT AVG(embedding)::vector(1536)
    INTO avg_embedding
    FROM articles
    WHERE thread_id = thread_id_param
    AND embedding IS NOT NULL;

    -- Update thread embedding if we have valid average
    IF avg_embedding IS NOT NULL THEN
        UPDATE threads
        SET embedding = avg_embedding,
            updated_at = NOW()
        WHERE id = thread_id_param;
    END IF;
END;
$$;

-- Function to update thread entity aggregation when articles are added
CREATE OR REPLACE FUNCTION update_thread_entity_aggregation(thread_id_param int)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing aggregations for this thread
    DELETE FROM thread_entities WHERE thread_id = thread_id_param;
    
    -- Insert new aggregations based on all articles in the thread
    INSERT INTO thread_entities (thread_id, entity_name, sentiment_sum, sentiment_count, first_seen_at, last_updated_at)
    SELECT 
        thread_id_param,
        entity_data->>'entity' as entity_name,
        SUM((entity_data->>'sentiment')::FLOAT) as sentiment_sum,
        COUNT(*) as sentiment_count,
        MIN(a.created_at) as first_seen_at,
        NOW() as last_updated_at
    FROM articles a
    CROSS JOIN LATERAL jsonb_array_elements(a.sentiment_entity_specific) as entity_data
    WHERE a.thread_id = thread_id_param
      AND a.sentiment_entity_specific IS NOT NULL
      AND jsonb_array_length(a.sentiment_entity_specific) > 0
      AND entity_data->>'entity' IS NOT NULL
      AND entity_data->>'sentiment' IS NOT NULL
    GROUP BY entity_data->>'entity'
    ON CONFLICT (thread_id, entity_name) 
    DO UPDATE SET
        sentiment_sum = EXCLUDED.sentiment_sum,
        sentiment_count = EXCLUDED.sentiment_count,
        last_updated_at = EXCLUDED.last_updated_at;
END;
$$;

-- Function to update thread article snapshots when articles are added
CREATE OR REPLACE FUNCTION update_thread_article_snapshots(thread_id_param int)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    new_snapshots jsonb;
BEGIN
    -- Build snapshots array from all articles in the thread
    SELECT jsonb_agg(
        jsonb_build_object(
            'article_id', a.id,
            'source', a.source,
            'title', a.title,
            'image', a.image
        ) ORDER BY a.created_at DESC
    )
    INTO new_snapshots
    FROM articles a
    WHERE a.thread_id = thread_id_param
    AND a.id IS NOT NULL;

    -- Update thread with new snapshots
    IF new_snapshots IS NOT NULL THEN
        UPDATE threads
        SET article_snapshots = new_snapshots,
            updated_at = NOW()
        WHERE id = thread_id_param;
    END IF;
END;
$$;

-- Grant execute permissions on RPC functions
GRANT EXECUTE ON FUNCTION find_similar_threads TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION update_thread_embedding TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION update_thread_entity_aggregation TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION update_thread_article_snapshots TO anon, authenticated, service_role;

-- Create blacklist table
CREATE TABLE IF NOT EXISTS blacklist (
    id SERIAL PRIMARY KEY,
    domain TEXT UNIQUE NOT NULL,
    skip_reader_mode BOOLEAN DEFAULT FALSE,
    skip_scrape BOOLEAN DEFAULT FALSE,
    examples TEXT[] DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for blacklist
CREATE INDEX IF NOT EXISTS idx_blacklist_domain ON blacklist(domain);

-- Enable RLS for blacklist
ALTER TABLE blacklist ENABLE ROW LEVEL SECURITY;

-- Blacklist policies - anyone can view
DROP POLICY IF EXISTS "Anyone can view blacklist" ON blacklist;
CREATE POLICY "Anyone can view blacklist" ON blacklist FOR SELECT USING (true);
DROP POLICY IF EXISTS "Authenticated users can manage blacklist" ON blacklist;
CREATE POLICY "Authenticated users can manage blacklist" ON blacklist FOR ALL USING (auth.role() = 'authenticated');

-- Add updated_at trigger for blacklist
DROP TRIGGER IF EXISTS update_blacklist_updated_at ON blacklist;
CREATE TRIGGER update_blacklist_updated_at 
    BEFORE UPDATE ON blacklist 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create failure_log table
CREATE TABLE IF NOT EXISTS failure_log (
    id SERIAL PRIMARY KEY,
    operation TEXT NOT NULL,
    error_message TEXT NOT NULL,
    extra TEXT DEFAULT NULL,
    owner TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for failure_log
CREATE INDEX IF NOT EXISTS idx_failure_log_operation ON failure_log(operation);
CREATE INDEX IF NOT EXISTS idx_failure_log_owner ON failure_log(owner);
CREATE INDEX IF NOT EXISTS idx_failure_log_created_at ON failure_log(created_at);

-- Enable RLS for failure_log
ALTER TABLE failure_log ENABLE ROW LEVEL SECURITY;

-- Failure log policies - anyone can view and insert
DROP POLICY IF EXISTS "Anyone can view failure log" ON failure_log;
CREATE POLICY "Anyone can view failure log" ON failure_log FOR SELECT USING (true);
DROP POLICY IF EXISTS "Anyone can insert failure log" ON failure_log;
CREATE POLICY "Anyone can insert failure log" ON failure_log FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Authenticated users can manage failure log" ON failure_log;
CREATE POLICY "Authenticated users can manage failure log" ON failure_log FOR ALL USING (auth.role() = 'authenticated');

-- Add updated_at trigger for failure_log
DROP TRIGGER IF EXISTS update_failure_log_updated_at ON failure_log;
CREATE TRIGGER update_failure_log_updated_at 
    BEFORE UPDATE ON failure_log 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create admin user for system operations
INSERT INTO users (id, user_id, created_at, updated_at)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'admin',
  NOW(),
  NOW()
)
ON CONFLICT (id) DO NOTHING; 