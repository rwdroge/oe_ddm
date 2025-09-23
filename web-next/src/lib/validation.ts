// Frontend validation helpers for DDM
// Rules for Authorization Tags:
// - Must begin with #DDM_See_ (case-insensitive)
// - Max length 64
// - Allowed characters: A-Z, a-z, 0-9, and the following specials: _ . - # $ % &
// - No spaces
// - Must contain non-empty content after the required prefix

const AUTH_TAG_PREFIX = '#DDM_See_'

// Matches allowed characters only (used after we do explicit prefix/suffix checks)
const AUTH_TAG_ALLOWED_CHARS = /^[A-Za-z0-9_.\-#$%&]+$/

export function isValidAuthorizationTag(tag: string): boolean {
  if (!tag || typeof tag !== 'string') return false
  if (tag.length > 64) return false

  const lower = tag.toLowerCase()
  const prefixLower = AUTH_TAG_PREFIX.toLowerCase()
  if (!lower.startsWith(prefixLower)) return false

  // Must have non-empty content after prefix
  if (tag.length <= AUTH_TAG_PREFIX.length) return false

  // No spaces
  if (tag.includes(' ')) return false

  // Allowed characters only
  if (!AUTH_TAG_ALLOWED_CHARS.test(tag)) return false

  return true
}

export function getAuthorizationTagValidationError(tag: string): string | null {
  if (!tag || typeof tag !== 'string') return 'Authorization tag is required'
  if (tag.length > 64) return 'Authorization tag must be at most 64 characters'
  if (tag.includes(' ')) return 'Authorization tag cannot contain spaces'

  const lower = tag.toLowerCase()
  const prefixLower = AUTH_TAG_PREFIX.toLowerCase()
  if (!lower.startsWith(prefixLower)) return `Authorization tag must start with "${AUTH_TAG_PREFIX}" (case-insensitive)`
  if (tag.length <= AUTH_TAG_PREFIX.length) return 'Authorization tag must include characters after the required prefix'
  if (!AUTH_TAG_ALLOWED_CHARS.test(tag)) return 'Allowed characters: A-Z, a-z, 0-9, and _ . - # $ % &'
  return null
}

export const AUTH_TAG_PREFIX_CONST = AUTH_TAG_PREFIX
