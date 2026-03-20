//
//  SupabaseConfig.swift
//  Luma
//

import Foundation

enum SupabaseConfig {
    static let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        ?? "https://bikvyomatpnktvjpkfai.supabase.co"

    static let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        ?? ""
}
