// Browser-side Supabase client
import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

// Debug logging
console.log('🔍 Supabase Client Init:');
console.log('  URL:', PUBLIC_SUPABASE_URL);
console.log('  Key exists:', !!PUBLIC_SUPABASE_ANON_KEY);
console.log('  Key length:', PUBLIC_SUPABASE_ANON_KEY?.length || 0);

if (!PUBLIC_SUPABASE_URL || !PUBLIC_SUPABASE_ANON_KEY) {
  console.error('❌ MISSING SUPABASE ENV VARS!');
  console.error('  URL:', PUBLIC_SUPABASE_URL);
  console.error('  Key:', PUBLIC_SUPABASE_ANON_KEY);
}

export const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});
