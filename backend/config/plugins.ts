import type { Core } from '@strapi/strapi';

const allowedMediaTypes = [
  'image/*',
  'video/*',
  'audio/*',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.*',
  'text/plain',
  'text/csv',
];

const deniedTypes = [
  'image/svg+xml',
  'application/vnd.microsoft.portable-executable',
  'application/x-msdownload',
  'application/x-msdos-program',
  'application/x-executable',
  'application/x-dosexec',
  'application/x-sh',
  'text/x-shellscript',
  'application/x-mach-binary',
];

const config = ({ env }: Core.Config.Shared.ConfigParams): Core.Config.Plugin => ({
  'users-permissions': {
    config: {
      jwtManagement: 'refresh',
      jwt: {
        expiresIn: '30d',
      },
      ratelimit: {
        interval: 60000,
        max: 200,
      },
      sessions: {
        accessTokenLifespan: 7 * 24 * 60 * 60, // 7 days
        maxRefreshTokenLifespan: 30 * 24 * 60 * 60, // 30 days
        idleRefreshTokenLifespan: 14 * 24 * 60 * 60, // 14 days
        maxSessionLifespan: 30 * 24 * 60 * 60, // 30 days
        idleSessionLifespan: 7 * 24 * 60 * 60, // 7 days
        httpOnly: false,
      },
    },
  },
  upload: {
    config: {
      security: {
        allowedTypes: allowedMediaTypes,
        deniedTypes,
      },
    },
  },
});

export default config;
