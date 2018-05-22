puppet_approved_criteria.markdown: approved.rb
	grep '^# ' approved.rb | sed  's/^# //' > puppet_approved_criteria.markdown
