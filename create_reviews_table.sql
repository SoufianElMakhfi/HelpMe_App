-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  reviewer_id UUID REFERENCES auth.users(id) NOT NULL, -- Who writes the review
  reviewee_id UUID REFERENCES auth.users(id) NOT NULL, -- Who receives the review
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read reviews (to show in profiles)
DROP POLICY IF EXISTS "Public read reviews" ON reviews;
CREATE POLICY "Public read reviews" ON reviews FOR SELECT USING (true);

-- Policy: Only participants of the job can create a review
-- Condition: The reviewer must be the logged-in user AND part of the job (customer or accepted craftsman)
DROP POLICY IF EXISTS "Participants can review" ON reviews;
CREATE POLICY "Participants can review" ON reviews FOR INSERT WITH CHECK (
  auth.uid() = reviewer_id 
  AND EXISTS (
    SELECT 1 FROM jobs 
    LEFT JOIN job_applications ON jobs.id = job_applications.job_id
    WHERE jobs.id = reviews.job_id 
    AND (
      jobs.customer_id = auth.uid() -- Reviewer is Customer
      OR (job_applications.craftsman_id = auth.uid() AND job_applications.status = 'accepted') -- Reviewer is Craftsman
    )
  )
);

-- Policy: Users can only update/delete their own reviews
DROP POLICY IF EXISTS "Users can edit own reviews" ON reviews;
CREATE POLICY "Users can edit own reviews" ON reviews FOR ALL USING (auth.uid() = reviewer_id);
