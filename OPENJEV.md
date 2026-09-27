# OpenJEV support

This fork adds optional [OpenJEV](https://openjev.sh) support alongside the original TypeSafe Jev integration. OpenJEV is a free community gateway to the same Jev model built by TypeSafe. TypeSafe stays the default; anyone with a TypeSafe key sees zero behaviour change.

## What was added

- `macros/config.sql` — `provider()`, `api_url()`, `api_model()`, `egress_host()` macros, and `secret_name()` now branches on provider.
- `macros/setup/handler.sql` — `URL` and `MODEL` are templated from `jevflake.api_url()` / `jevflake.api_model()` instead of hardcoded.
- `macros/setup/setup.sql` — network rule uses `jevflake.egress_host()` instead of a hardcoded host.
- `scripts/sync_terraform_handler.py` — handles the new `api_url()` expression.
- `terraform/handler.py.tftpl` — `URL` is now `${jsonencode(url)}`.
- `terraform/variables.tf` — `provider`, `openjev_api_key`, `openjev_existing_secret`, `openjev_secret_name` variables.
- `terraform/main.tf` — branches on `var.provider` for URL, model, egress host, secret, and comments.
- `terraform/outputs.tf` — `model` and `secret` outputs use the effective provider values.
- `terraform/README.md`, `README.md`, `SECURITY.md` — document the new option.

## Provider selection rule

1. Explicit choice wins: set `jevflake_provider` dbt var (or Terraform `provider` input) to `openjev`.
2. Otherwise, TypeSafe is the default (unchanged) — the functions call `https://api.typesafe.ai/v1/systemone` with model `jev-1.13.0` and read the `jev_api_key` secret.
3. When `openjev` is selected — the functions call `https://api.openjev.sh/v1/systemone` with model `openjev`, the network rule allows `api.openjev.sh:443`, and the secret defaults to `jev_openjev_api_key` (override with `jevflake_openjev_secret` / `openjev_secret_name`).

## How to configure (dbt)

```yaml
vars:
  jevflake_provider: openjev
  jevflake_openjev_secret: ANALYTICS.JEVFLAKE.JEV_OPENJEV_API_KEY
```

Store the OpenJEV API key as a Snowflake secret:

```sql
create secret analytics.jevflake.jev_openjev_api_key
  type = generic_string
  secret_string = 'your-openjev-api-key';
```

Then run `dbt run-operation jevflake.setup`.

## How to configure (Terraform)

```hcl
module "jevflake" {
  source = "github.com/openjevai/Jevflake//terraform?ref=openjev"

  database             = "ANALYTICS"
  provider             = "openjev"
  openjev_api_key      = var.openjev_api_key  # or openjev_existing_secret
  caller_roles         = ["TRANSFORMER"]
}
```

## Verification

A live `POST https://api.openjev.sh/v1/systemone` request with model `openjev`, state `ping`, and one noul question returned HTTP 200. Re-grep confirms no hardcoded `api.typesafe.ai` default remains in the handler or network rule — the host is derived from the provider setting.

## Upstream

Original project: https://github.com/KranzL/Jevflake by @KranzL.
