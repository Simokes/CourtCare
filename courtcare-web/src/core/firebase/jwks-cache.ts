// SERVER-SIDE ONLY (Edge Runtime) — used exclusively by middleware.ts
// jose createRemoteJWKSet handles caching and TTL automatically
import { createRemoteJWKSet } from "jose";

const FIREBASE_JWKS_URL = new URL(
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
);

// getJwks is a JWTVerifyGetKey function — pass directly to jwtVerify()
export const getJwks = createRemoteJWKSet(FIREBASE_JWKS_URL);
