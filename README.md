# CorGe
CorGe (Correspondence Generator) is a configurable ruby template processor developed for automated correspondence.

# Dependencies
- Ruby v2.0.0
- mail gem

# Usage
1. Prepare CSV, the title row will be interpreted as variable names for the template.
```
First Name,Last Name,Email,Phone Number
```
2. Create a new template using {Variable Name} for replacement.
```
{First Name},{Last Name},{Email},{Phone Number}
```
3. Customize options in config.yml
4. run "Ruby CorGe.rb"