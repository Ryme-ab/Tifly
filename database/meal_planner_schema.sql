-- SQL Schema for Meal Planner Feature
-- This script creates the planned_meals table in Supabase

-- Create the planned_meals table
CREATE TABLE IF NOT EXISTS planned_meals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    child_id UUID NOT NULL,
    date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    title VARCHAR(255) NOT NULL,
    subtitle TEXT,
    is_done BOOLEAN DEFAULT FALSE,
    ingredients TEXT,
    recipe TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_planned_meals_user_id ON planned_meals(user_id);
CREATE INDEX IF NOT EXISTS idx_planned_meals_child_id ON planned_meals(child_id);
CREATE INDEX IF NOT EXISTS idx_planned_meals_date ON planned_meals(date);
CREATE INDEX IF NOT EXISTS idx_planned_meals_user_child_date ON planned_meals(user_id, child_id, date);

-- Enable Row Level Security (RLS)
ALTER TABLE planned_meals ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy: Users can only view their own planned meals
CREATE POLICY "Users can view own planned meals"
    ON planned_meals
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own planned meals
CREATE POLICY "Users can insert own planned meals"
    ON planned_meals
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own planned meals
CREATE POLICY "Users can update own planned meals"
    ON planned_meals
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own planned meals
CREATE POLICY "Users can delete own planned meals"
    ON planned_meals
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_planned_meals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER trigger_update_planned_meals_updated_at
    BEFORE UPDATE ON planned_meals
    FOR EACH ROW
    EXECUTE FUNCTION update_planned_meals_updated_at();

-- Grant necessary permissions (adjust as needed)
GRANT ALL ON planned_meals TO authenticated;
GRANT ALL ON planned_meals TO service_role;

-- Sample data insertion (optional - for testing)
-- INSERT INTO planned_meals (user_id, child_id, date, meal_type, title, subtitle, is_done, ingredients, recipe)
-- VALUES 
--     (auth.uid(), 'your-child-id', '2025-12-23', 'breakfast', 'Oatmeal Cereal', 'Healthy breakfast for baby', false, 'Oat flour, Water or breast milk', 'Mix oat flour with warm water or breast milk until smooth'),
--     (auth.uid(), 'your-child-id', '2025-12-23', 'lunch', 'Pureed Vegetables', 'Carrot and sweet potato puree', false, 'Carrots, Sweet potatoes', 'Steam vegetables until soft, blend until smooth'),
--     (auth.uid(), 'your-child-id', '2025-12-23', 'dinner', 'Banana Mash', 'Simple and nutritious', true, 'Ripe banana', 'Mash ripe banana with a fork until smooth');
