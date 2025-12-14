# Changelog

All notable changes to the WhoKnows application will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-13

### Added - Security Enhancements
- Enhanced user model with comprehensive validations:
  - Username length constraints (3-50 characters)
  - Email format validation using RFC standard
  - Password minimum length of 8 characters
  - Email uniqueness validation
- Improved session security configuration:
  - Added `httponly: true` flag to prevent XSS attacks
  - Session expiration after 24 hours
  - `same_site: :lax` for CSRF protection
  - `secure: true` in production for HTTPS-only cookies

### Added - Performance Optimizations
- Optimized search queries:
  - Added result limiting (100 max results)
  - Implemented selective field loading with `.select()`
  - Query normalization for better performance
- Enhanced error handling in search logging
- Async search logging to prevent request blocking

### Added - Monitoring & Health Checks
- New health check endpoints:
  - `/health` - Basic health status
  - `/health/ready` - Readiness probe with dependency checks
  - `/health/live` - Liveness probe with uptime tracking
  - `/health/metrics` - Application metrics summary
- Application boot time tracking for uptime calculations
- Version tracking in application configuration

### Added - Backup & Restore System
- Comprehensive backup scripts:
  - `backup_database.ps1` - Manual backup creation (Windows)
  - `backup_database.sh` - Manual backup creation (Linux/Mac)
  - `restore_database.ps1` - Database restoration (Windows)
  - `restore_database.sh` - Database restoration (Linux/Mac)
  - `scheduled_backup.ps1` - Automated backup with logging
  - `setup_backup_schedule.ps1` - Windows Task Scheduler setup
  - `verify_backup.ps1` - Backup integrity verification
- Automatic backup compression (gzip)
- Configurable retention period (default: 7 days)
- Backup verification with integrity checks

### Added - Documentation
- [API Documentation](./docs/API.md) - Complete API reference with examples
- [Maintenance Guide](./docs/MAINTENANCE.md) - Comprehensive operational procedures
- `.env.example` - Environment configuration template
- Updated README.md with:
  - Security features
  - Performance optimizations
  - Backup/restore procedures
  - Monitoring endpoints
  - Maintenance schedule

### Added - Middleware & Error Handling
- Rate limiting middleware (prepared but not yet enabled):
  - Login attempts: 5 per minute
  - Registration: 3 per 5 minutes
  - Search: 100 per minute
  - Weather API: 20 per minute
- Error handler middleware with custom error pages
- Graceful error recovery with appropriate status codes

### Improved
- Search controller with better error handling and result counting
- Logging throughout the application with structured messages
- Code quality and maintainability

### Fixed
- Potential nil reference in search content truncation
- Missing error handling in password change operations
- Session security vulnerabilities

### Security
- Zero security vulnerabilities (verified with Brakeman 7.1.1)
- All tests passing (118 examples, 0 failures, 0 pending)
- Code compliant with Rubocop standards

### Documentation Updates
- Added maintenance schedule (daily, weekly, monthly, quarterly tasks)
- Added troubleshooting guide
- Added backup strategy documentation
- Added monitoring metrics documentation
- Added security procedures

---

## [0.0.1]

### Added
- Initial pre-release: authentication, search endpoint, weather lookup, basic monitoring hooks.

---

## Version History

### Version Numbering
- **Major version (X.0.0)**: Breaking changes, major features
- **Minor version (0.X.0)**: New features, improvements (backward compatible)
- **Patch version (0.0.X)**: Bug fixes, security patches

### Upcoming Features (Roadmap)
- [ ] Redis caching for improved performance
- [ ] Email notifications for account activities
- [ ] Two-factor authentication (2FA)
- [ ] Advanced search filters
- [ ] User profile management
- [ ] API rate limiting enforcement
- [ ] Real-time search suggestions
- [ ] Export functionality (CSV, JSON)
- [ ] Audit logging
- [ ] Advanced analytics dashboard

---

## Maintenance Notes

### Current Test Coverage
- Line Coverage: 100%
- Passing Tests: 118
- Failed Tests: 0
- Pending Tests: 0

### Dependencies
- Rails: 8.0.2
- Ruby: 3.4.6
- PostgreSQL: Latest
- Prometheus: Latest
- Grafana: OSS Latest

### Known Issues
- None at this time

### Breaking Changes
None in this release. All changes are backward compatible.

---

For more detailed information about maintenance procedures, see [MAINTENANCE.md](./docs/MAINTENANCE.md).
For API usage, see [API.md](./docs/API.md).
