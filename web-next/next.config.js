/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    typedRoutes: true,
  },
  async rewrites() {
    return [
      {
        source: '/api/masking/:path*',
        destination: 'http://sports2020-pas:8810/web/api/masking/:path*',
      },
    ]
  },
}

module.exports = nextConfig
