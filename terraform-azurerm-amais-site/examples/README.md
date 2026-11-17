# AMAIS Site Module - Examples

Each subdirectory contains a self-contained example showing how to enable a specific optional feature of the `amais-site` module. Copy the relevant settings into your site's `main.tf` as needed.

| Example                                                      | Description                                                                            |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| [form-payments](./form-payments)                             | Enable form payment processing                                                         |
| [ai-chatbot](./ai-chatbot)                                   | Enable the AI chatbot                                                                  |
| [calendar](./calendar)                                       | Configure calendar time zone settings                                                  |
| [sendgrid](./sendgrid)                                       | Email module, custom SendGrid configuration and SendGrid event receiver registration   |
| [captcha](./captcha)                                         | Cap captcha service registration (automatic) and site key rotation                     |
| [baseline-provisioning](./baseline-provisioning)             | Start a new site from the Baseline site content, one-off at creation                   |
| [workflows](./workflows)                                     | Enable the workflow engine                                                             |
| [blackbaud](./blackbaud)                                     | Blackbaud SSO and directory sync                                                       |
| [veracross](./veracross)                                     | Veracross SSO and directory sync                                                       |
| [gg4l](./gg4l)                                               | GG4L SSO and directory sync                                                            |
| [authorize-net](./authorize-net)                             | Authorize.Net payment integration                                                      |
| [bunny-waf-log-only](./bunny-waf-log-only)                   | Configure Bunny WAF and bot protection in log-only mode                                |
| [bunny-bot-exception](./bunny-bot-exception)                 | Add a Bunny edge rule to bypass bot detection for a specific user-agent                |
| [bunny-bot-exception-with-ip](./bunny-bot-exception-with-ip) | Add a Bunny edge rule to bypass bot detection matching on IP address and/or user-agent |
| [bunny-shield-verified-bots](./bunny-shield-verified-bots)   | Allow/block Bunny Shield verified bot categories and individual bots platform-wide     |
