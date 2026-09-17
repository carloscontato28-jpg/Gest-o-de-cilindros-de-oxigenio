// Configuração e inicialização do Supabase
const supabaseUrl = 'https://lejngceikccqvbithqeb.supabase.co';
const supabaseKey = 'sb_publishable_Nq6F6m9djpW2eU8l2fDHfA_LYSRUg2t';

let supabase;
try {
    if (window.supabase) {
        supabase = window.supabase.createClient(supabaseUrl, supabaseKey);
        console.log("Supabase client initialized.");
    } else {
        console.warn("Supabase library not found. Ensure it is loaded via CDN.");
    }
} catch (e) {
    console.warn("Failed to initialize Supabase client.", e);
}

// Exporta globalmente para uso na arquitetura sem build step
window.supabaseClient = supabase;
