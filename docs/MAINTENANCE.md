# WhoKnows Application - Maintenance Guide

## Overview
This document provides comprehensive maintenance guidelines for the WhoKnows search engine application.

## Last Updated
December 27, 2025

## Maintenance Tasks Completed

### 1. Security Enhancements
- **Password Security**: Enhanced password validation (minimum 8 characters)
- **Email Validation**: Added proper email format validation with RFC compliance
- **Username Validation**: Added length constraints (3-50 characters)
- **Session Security**: Configured secure session cookies with:
  - `httponly: true` - Prevents JavaScript access to cookies
  - `secure: true` (production) - Ensures HTTPS-only transmission
  - `same_site: :lax` - CSRF protection
  - `expire_after: 24.hours` - Automatic session expiration
- **Brakeman Security Scan**: Zero vulnerabilities detected
- **SSRF Mitigation**: Replaced `HTTParty` with `Faraday` to mitigate server-side request forgery (SSRF) risks.

### 2. Performance Optimizations
- **Search Query Optimization**:
  - Added result limiting (100 max results)
  - Implemented selective field loading with `.select()`
  - Normalized queries for better cache hits
- **Database Indexes**: Existing GIN indexes on pages table for full-text search
- **Connection Pooling**: Configured in database.yml (5 connections)
- **Error Handling**: Improved error handling in search logging

### 3. Code Quality
- **Rubocop Compliance**: Code passes linting standards
- **Test Coverage**: 149 passing tests, 0 failures
- **Error Handling**: Enhanced error recovery in critical paths

### 4. Logging & Monitoring
- **Prometheus Metrics**:
  - HTTP request tracking (total, duration)
  - User behavior (registrations, logins)
  - Weather API requests
  - Search requests
- **Application Logging**: Structured logging for:
  - User authentication events
  - Search queries
  - API errors

## Regular Maintenance Schedule

### Daily Tasks
- [ ] Monitor Grafana dashboards for anomalies
- [ ] Check application logs for errors
- [ ] Verify database connectivity
- [ ] Check disk space usage

### Weekly Tasks
- [ ] Review Prometheus metrics trends
- [ ] Analyze search logs for optimization opportunities
- [ ] Check for failed background jobs
- [ ] Review user registration patterns

### Monthly Tasks
- [ ] Update dependencies: `bundle update`
- [ ] Run security audit: `bundle exec brakeman`
- [ ] Review and rotate logs
- [ ] Database maintenance (VACUUM, ANALYZE)
- [ ] Review and update documentation
- [ ] Backup verification test

### Quarterly Tasks
- [ ] Major dependency updates
- [ ] Performance benchmarking
- [ ] Security penetration testing
- [ ] Disaster recovery drill
- [ ] Capacity planning review

## Monitoring & Alerting

### Key Metrics to Monitor
1. **System Health**:
   - CPU usage (target: < 70%)
   - Memory usage (target: < 80%)
   - Disk usage (target: < 80%)
   - Network traffic

2. **Application Performance**:
   - Response time (target: < 200ms p95)
   - Error rate (target: < 1%)
   - Request throughput

3. **Business Metrics**:
   - User registration rate
   - Search success rate
   - Weather API success rate

### Grafana Dashboards
Access Grafana at: http://localhost:5000
- System Overview Dashboard
- Application Metrics Dashboard
- PostgreSQL Performance Dashboard

### Prometheus Metrics Endpoint
Access metrics at: http://localhost:3000/metrics

## Backup & Recovery

### Database Backup Strategy
```bash
# Create backup
docker compose exec postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup_$(date +%Y%m%d).sql

# Create compressed backup
docker compose exec postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Restore Procedure
```bash
# Restore from backup
docker compose exec -T postgres psql -U $POSTGRES_USER $POSTGRES_DB < backup_20251213.sql

# Restore from compressed backup
gunzip -c backup_20251213.sql.gz | docker compose exec -T postgres psql -U $POSTGRES_USER $POSTGRES_DB
```

### Backup Schedule
- **Hourly**: Transaction log backups
- **Daily**: Full database backup (retained for 7 days)
- **Weekly**: Full system backup (retained for 4 weeks)
- **Monthly**: Archived backup (retained for 1 year)

### Backup Verification
Test restore procedure monthly to ensure backup integrity.

## Performance Tuning

### Database Optimization
```sql
-- Analyze tables for query planner
ANALYZE pages;
ANALYZE users;
ANALYZE search_logs;

-- Vacuum tables
VACUUM ANALYZE pages;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes 
ORDER BY idx_scan ASC;
```

### Application Tuning
- **Puma Workers**: Adjust based on CPU cores (currently 2)
- **Database Pool**: Match with Puma max threads (currently 5)
- **Cache Strategy**: Consider Redis for session store in production

## Security Maintenance

### SSL/TLS Certificates
- Certificate expiration monitoring
- Automatic renewal setup (Let's Encrypt recommended)
- Force HTTPS in production (currently enabled)

### Dependency Updates
```bash
# Check for security vulnerabilities
bundle audit check --update

# Update specific gems
bundle update gem_name

# Update all gems (test thoroughly)
bundle update
```

### Security Scanning
```bash
# Run Brakeman security scanner
bundle exec brakeman -A -q

# Check for outdated gems with known vulnerabilities
bundle audit
```

## Troubleshooting

### Common Issues

#### Database Connection Errors
```bash
# Check database status
docker compose ps postgres

# Restart database
docker compose restart postgres

# View database logs
docker compose logs postgres
```

#### Application Not Starting
```bash
# Check logs
docker compose logs web

# Restart application
docker compose restart web

# Rebuild if needed
docker compose up --build web
```

#### High Memory Usage
```bash
# Check container memory
docker stats

# Restart services
docker compose restart

# Clear logs if needed
truncate -s 0 log/development.log
```

## Contact Information

### On-Call Escalation
1. Application Developer (Primary)
2. DevOps Engineer (Secondary)
3. Database Administrator (Database issues)

### Support Resources
- GitHub Issues: https://github.com/devkopa/WhoKnows-next-gen/issues
- Documentation: ./docs/
- Monitoring: http://localhost:5000 (Grafana)

## Changelog

### 2025-12-27
- Fixed SSRF vulnerability by replacing `HTTParty` with `Faraday` (server-side request forgery mitigation)

### 2025-12-14
- Enhanced user model validations
- Improved session security
- Optimized search performance
- Created comprehensive maintenance documentation
