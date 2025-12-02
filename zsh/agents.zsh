function cc (){
	claude --dangerously-skip-permissions
}

function cci () {
	claude "/issues $@" --dangerously-skip-permissions
}

function ccw () {
	echo "Launching claude code"
	claude "/work_jira $@" --dangerously-skip-permissions
}