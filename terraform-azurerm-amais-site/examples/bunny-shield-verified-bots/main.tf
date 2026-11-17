module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## IMPORTANT: Supplied values will overwrite module defaults, if you need to add to the default config the full variable value with updates should be supplied, not just the delta.

  ## Allow verified AI/SEO bots platform-wide instead of case-by-case edge rules
  bunny_shield_category_actions = {
    # Supply all default categories to retain default behaviour for categories you don't want to change, and override the ones you want to change.
    SEO = {
      action = "Allow"
    }
    AIScraper = {
      action = "Allow"
    }
    AITool = {
      action        = "Allow"
      verified_only = false # Override default to allow unverifiable AI tool bots in this category - THIS IS NOT RECOMMENDED AND MUST BE APPROVED
    }
    Tool = {
      action = "Allow"
    }
    Ads = {
      action = "Allow"
    }
    Preview = {
      action = "Allow"
    }
    Social = {
      action = "Allow"
    }
  }

  ## Override a specific bot within an otherwise-blocked/ignored category, or force-block one bot
  bunny_shield_bot_actions = {
    # Supply default bot actions to retain default behaviour for bots you don't want to change, and override the ones you want to change.
    34 = "Allow" # Unverified facebookexternalhit that Bunny allows by default, suboptimal but is disruptive if blocked
    # Add additional bot overrides here, for example:
    12345 = "Allow"  # Allow just this specific bot overriding the category's action
    54321 = "Ignore" # Explicitly set the ignore action on a bot that would otherwise be allowed or blocked by the category's action
    6789  = "Block"  # known unwanted bot id for a pull zone requiring an exception
  }
}

/*
# You can find the available bot ids from the API, example pwsh:

$pullZoneId = '4234658' # Ubiq
$headers = @{ Accept = 'application/json'; AccessKey = '<BUNNY-API-KEY>' } # API key is in Bitwarden
$ubiqShieldZoneId = (Invoke-RestMethod -Uri "https://api.bunny.net/shield/shield-zone/get-by-pullzone/$pullZoneId" -Headers $headers -Method Get).data.shieldZoneId
Invoke-RestMethod -Uri "https://api.bunny.net/shield/shield-zone/$ubiqShieldZoneId/bot-categorization" -Headers $headers -Method Get | ConvertTo-Json -Depth 100
*/
