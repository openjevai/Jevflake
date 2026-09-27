{% macro database_name() %}
  {{ return(jevflake.assert_identifier(var('jevflake_database', target.database), 'database')) }}
{% endmacro %}


{% macro schema_name() %}
  {{ return(jevflake.assert_identifier(var('jevflake_schema', 'jevflake'), 'schema')) }}
{% endmacro %}


{% macro namespace() %}
  {{ return(jevflake.database_name() ~ '.' ~ jevflake.schema_name()) }}
{% endmacro %}


{% macro function_name(name) %}
  {{ return(jevflake.namespace() ~ '.' ~ name) }}
{% endmacro %}


{% macro secret_name() %}
  {% if jevflake.provider() == 'openjev' %}
    {{ return(jevflake.assert_dotted_name(var('jevflake_openjev_secret', jevflake.namespace() ~ '.jev_openjev_api_key'), 'secret')) }}
  {% else %}
    {{ return(jevflake.assert_dotted_name(var('jevflake_secret', jevflake.namespace() ~ '.jev_api_key'), 'secret')) }}
  {% endif %}
{% endmacro %}


{% macro network_rule_name() %}
  {{ return(jevflake.namespace() ~ '.' ~ jevflake.assert_identifier(var('jevflake_network_rule', 'jev_egress'), 'network rule')) }}
{% endmacro %}


{% macro integration_name() %}
  {{ return(jevflake.assert_identifier(var('jevflake_integration', 'jev_access'), 'integration')) }}
{% endmacro %}


{% macro model_name() %}
  {{ return(var('jevflake_model', 'jev-1.13.0')) }}
{% endmacro %}


{% macro provider() %}
  {{ return(var('jevflake_provider', 'typesafe')) }}
{% endmacro %}


{% macro api_url() %}
  {% if jevflake.provider() == 'openjev' %}
    {{ return('https://api.openjev.sh/v1/systemone') }}
  {% else %}
    {{ return('https://api.typesafe.ai/v1/systemone') }}
  {% endif %}
{% endmacro %}


{% macro api_model() %}
  {% if jevflake.provider() == 'openjev' %}
    {{ return('openjev') }}
  {% else %}
    {{ return(jevflake.model_name()) }}
  {% endif %}
{% endmacro %}


{% macro egress_host() %}
  {% if jevflake.provider() == 'openjev' %}
    {{ return('api.openjev.sh:443') }}
  {% else %}
    {{ return('api.typesafe.ai:443') }}
  {% endif %}
{% endmacro %}


{% macro function_signatures() %}
  {% set signatures = [jevflake.function_name('jev_ask_json') ~ '(varchar, varchar)'] %}
  {% for state_type in ['variant', 'varchar'] %}
    {% do signatures.append(jevflake.function_name('jev_ask') ~ '(' ~ state_type ~ ', variant)') %}
    {% do signatures.append(jevflake.function_name('jev_noul') ~ '(' ~ state_type ~ ', varchar)') %}
    {% do signatures.append(jevflake.function_name('jev_noul') ~ '(' ~ state_type ~ ', varchar, variant)') %}
    {% do signatures.append(jevflake.function_name('jev_choice') ~ '(' ~ state_type ~ ', varchar, variant)') %}
    {% do signatures.append(jevflake.function_name('jev_score') ~ '(' ~ state_type ~ ', varchar, variant)') %}
  {% endfor %}
  {{ return(signatures) }}
{% endmacro %}
