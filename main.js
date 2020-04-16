const { Octokit } = require ('@octokit/rest') ;
const octokit = new Octokit () ;

const checkIfFileExists = async (owner, repo) => {
	try {
		await octokit.repos.getContents({
			owner,
			repo,
			path:'.github/workflows'
		}).then(({data}) => {
			console.log(data)
		})
	} catch (error) {
		if (error.status === 404) {
			console.log('.github/workflows does not exist')
		} else {
			console.log('connection error')
		}
	}
}

checkIfFileExists('timkinsman', 'octofile')