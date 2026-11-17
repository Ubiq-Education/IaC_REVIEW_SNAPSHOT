locals {
  main_app_roles = {
    "f6891d7c-cd0b-44ef-ac4a-a18454d34948" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "all"
    }
    "d4ecf7b3-c8c0-4834-a7fd-680643347680" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "analytics:conversion"
    }
    "19e0064b-7517-4d5d-b7b3-83b44b217948" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "analytics:leadscore"
    }
    "ae138b93-d682-47d2-97ce-85fb2b6b496a" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "analytics:persona"
    }
    "25aad49b-b2bf-4c26-976c-630dad4af041" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "analytics:touchpoint"
    }
    "aa587eba-4e9d-440f-9b5a-180c95b96695" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "analytics:audience"
    }
    "9c246708-2549-4475-922a-371e03b869ec" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:abtest:totals"
    }
    "a248641a-6510-4269-bf0e-5da9f8de765a" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:conversion:by:time"
    }
    "c26d96e1-757e-4d0f-9a76-72f8212dc696" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:conversion:totals"
    }
    "56dfcf22-0f54-430a-a599-dcfbcbddab0e" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:leadscore:by:time"
    }
    "7780898d-af3f-4b41-9b76-a01d5c91552a" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:leadscore:totals:by:stage"
    }
    "b6d5eeaf-e39a-4e31-81cc-7d00eec6dafa" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:persona:by:time"
    }
    "c18f549a-5f78-4c47-84f3-d5dd7642e2ea" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:persona:totals"
    }
    "9afdbac2-456e-4b40-8404-6759e28b6816" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:personalization:totals"
    }
    "e83f80d5-a674-4eba-9fa0-d78d4a2812bb" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:touchpoint:by:time"
    }
    "0f8f9823-48a5-4d6c-a8cf-606fe06b9440" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "get:touchpoint:totals"
    }
    "5fc25705-9c19-4c51-9890-17fa842b075b" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:abtest:totals"
    }
    "0800ad5b-72e7-4e35-8e06-427f51e4a6f7" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:contacts"
    }
    "18220dba-7ffe-40b7-9b4d-4b14a8a4ca51" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:conversions:by:time"
    }
    "a8a2371a-a689-4ce4-a57e-60e7780852b1" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:conversions:totals"
    }
    "b5aeecab-2e60-4a81-8427-ad2d34e54af6" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:documents"
    }
    "a0fac118-c9b5-46be-a04f-eaf9f96dd54b" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:leadscores:totals:by:stage"
    }
    "d433b6a7-5c7b-4c58-9155-3b5d1c4dc081" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:personalization:totals"
    }
    "9cc524ef-6679-4158-ae4d-dd9776d25bcb" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:personas:by:time"
    }
    "0df8ef21-fac3-4533-861e-91f93c00e704" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:personas:link:subject"
    }
    "7de1a98b-e5ab-405c-82b1-67eeee499892" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:top:leadscores:by:time"
    }
    "38e1a86c-6ec2-43b8-857e-b4dc9322c776" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:top:personas:by:time"
    }
    "789d7bc8-bd7a-4bcd-a5bd-fad014289ff4" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:touchpoints:by:time"
    }
    "1fb690d9-a667-44f6-b5fb-4e93767e126c" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:touchpoints:totals"
    }
    "122e6274-de32-4e19-b3b5-edb8ba0b25fa" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "list:visitors:by:time"
    }
    "72e79a5a-af79-4745-94a4-2e4ff10d7472" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "preview:audience"
    }
    "212551cc-fe31-4993-95e7-8ddc4d9628d0" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "post:interaction"
    }
    "cc7fadf2-7f0f-4947-838a-12b0701d4562" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "post:notification:emails"
    }
    "9c821b38-4035-4cce-a7b3-8baf010787f1" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "chatbot:ai"
    }
    "ebac9852-5d39-4697-898b-ae8f558a8612" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "audience:ai"
    }
    "770c66f3-135a-4643-98cb-40873941c04e" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "chatbot:read:all"
    }
  }
}
