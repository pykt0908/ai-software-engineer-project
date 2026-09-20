/**
 * ai-caption-log router
 * Core CRUD is not exposed via users-permissions bootstrap.
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreRouter('api::ai-caption-log.ai-caption-log');
