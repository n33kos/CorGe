# CorGe
CorGe (Correspondence Generator) is a configurable ruby template processor developed for automated correspondence.

# Dependencies
- Ruby v2.0.0
- Gems:
	- mail
	- highline

# Usage
- Prepare CSV, the title row will be interpreted as variable names for the template. The first column title will be used in the file name.
- Create your template using {Variable Name} for replacement. There are several special variables which will be automagically inserted into the email(email,attachments,subject)
- Customize options in config.yml
- Run "Ruby CorGe.rb" or use the arguments for stdin/stdout

# Arguments
```ruby CorGe.rb``` - Loads UI
```ruby CorGe.rb generate``` - Generates messages from CSV
```ruby CorGe.rb list``` - Lists Generated Messages
```ruby CorGe.rb list sent``` - Lists Generated Messages
```ruby CorGe.rb read``` - Read message(s) from path
```ruby CorGe.rb sent``` - Mark message(s) as sent 
```ruby CorGe.rb delete``` - Delete all sent messages