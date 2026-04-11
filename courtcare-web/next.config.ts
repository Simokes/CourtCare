import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Ensure firebase-admin is not bundled client-side
  serverExternalPackages: ["firebase-admin"],
};

export default nextConfig;
