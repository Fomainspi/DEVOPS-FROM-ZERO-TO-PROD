# DAY 5 — GITHUB & COLLABORATION

> Foundation of Mastering Automation (FOMA)  
> Course: DevOps from Zero to Production  
> Trainer: William Foma

## 1. Objectives

By the end of Day 5 you can:

- create and manage GitHub repositories
- connect local Git to GitHub
- use clone, fetch, pull and push
- work with feature branches
- open and review Pull Requests
- manage Issues and Projects
- create a basic GitHub Actions CI workflow
- protect credentials and collaborate professionally
- troubleshoot common GitHub failures

## 2. Git and GitHub

Git is distributed version control. GitHub hosts Git repositories and adds collaboration, review, Issues, Projects and Actions.

Think of the workflow as:

~~~text
WORKSTATION
working tree → staging → commit
                         ↓
                      push
                         ↓
GITHUB
repository → Pull Request → review → CI → merge
~~~

Git does not require GitHub. GitHub does not replace knowledge of Git.

## 3. Create and publish a repository

~~~bash
mkdir foma-github-lab
cd foma-github-lab
git init
git branch -M main
echo "# FOMA GitHub Lab" > README.md
git add README.md
git commit -m "docs: add initial README"

git remote add origin https://github.com/USERNAME/foma-github-lab.git
git push -u origin main
~~~

Verify:

~~~bash
git remote -v
git status
git log --oneline --decorate --graph --all
~~~

Never place passwords, tokens or private keys in commands that can be saved in shell history.

## 4. Remote repositories

Clone:

~~~bash
git clone https://github.com/USERNAME/foma-github-lab.git
cd foma-github-lab
~~~

Fetch remote history:

~~~bash
git fetch origin
~~~

Fetch downloads remote information without automatically integrating it into your current branch.

Pull:

~~~bash
git pull --ff-only origin main
~~~

Push:

~~~bash
git push origin main
~~~

Use SSH keys or a supported HTTPS credential mechanism. GitHub no longer uses normal account passwords for Git over HTTPS.

## 5. Branching

A branch isolates work.

~~~bash
git switch -c feature/health-check
echo "Health check documentation" >> README.md
git add README.md
git commit -m "docs: add health check"
git push -u origin feature/health-check
~~~

Recommended beginner model:

~~~text
main
 ├── feature/login
 ├── feature/health-check
 └── fix/api-timeout
~~~

Keep branches short-lived and focused.

## 6. Pull Requests

A Pull Request proposes a change from one branch into another.

A professional PR explains:

- what changed
- why it changed
- how it was tested
- operational or security impact

Example:

~~~text
Title: feat: add API health check

What changed:
Added GET /health documentation and tests.

Testing:
pytest -q
curl http://localhost:5000/health

Risk:
Low; backward-compatible endpoint.
~~~

Keep PRs small enough to review carefully.

## 7. Code review

Review the system, not the person.

Check:

- correctness
- tests
- readability
- security
- performance
- operational impact
- maintainability
- unnecessary complexity

Good review feedback is specific and actionable.

~~~text
Could we validate this value before passing it to the command?
That would prevent unexpected shell arguments.
~~~

## 8. Issues and Projects

Issues can track bugs, features, documentation, technical debt and follow-up work.

A useful issue contains:

~~~text
Problem
Expected behavior
Steps to reproduce
Acceptance criteria
~~~

Projects can provide a Kanban workflow:

~~~text
TO DO → IN PROGRESS → REVIEW → DONE
~~~

Keep work items small and measurable.

## 9. GitHub Actions

GitHub Actions can automatically test code when a push or Pull Request occurs.

Create .github/workflows/ci.yml:

~~~yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Run tests
        run: pytest -q
~~~

Mental model:

~~~text
push / Pull Request
        ↓
GitHub Actions
        ↓
checkout → install → test
        ↓
PASS → continue
FAIL → fix
~~~

## 10. Collaboration best practices

Use meaningful commit messages:

~~~text
feat: add health endpoint
fix: handle missing configuration
docs: update deployment guide
test: add API health checks
ci: add Python test workflow
refactor: simplify deployment script
~~~

Avoid messages such as:

~~~text
fix
update
changes
stuff
~~~

Protect secrets. Never commit:

~~~text
.env
*.pem
*.key
credentials.json
cloud access keys
private certificates
~~~

Use GitHub Secrets or a dedicated secret manager for CI/CD credentials.

## 11. Hands-on project

Create foma-collaboration-lab.

1. Create a GitHub repository.
2. Push a local README.
3. Create feature/health-check.
4. Add health endpoint documentation.
5. Open a Pull Request.
6. Review the PR.
7. Create an Issue for automated tests.
8. Add a GitHub Actions test workflow.
9. Deliberately create a failing test.
10. Observe the failed workflow.
11. Fix it and push again.
12. Merge after validation.

## 12. Troubleshooting

### Authentication failed

Check the remote:

~~~bash
git remote -v
~~~

If using SSH:

~~~bash
ssh -T git@github.com
~~~

### Permission denied

Verify repository access, remote URL and the account/key being used.

### Non-fast-forward

First inspect remote history:

~~~bash
git fetch origin
git log --oneline --decorate --graph --all
~~~

Then integrate safely:

~~~bash
git pull --rebase origin main
git push origin main
~~~

### Merge conflict

~~~bash
git status
~~~

Edit the conflicted file, choose the intended result, then:

~~~bash
git add FILE
git commit
~~~

### Actions failure

Read the first meaningful error in the workflow log. Check runtime version, dependency installation, working directory, missing variables and test output.

## 13. Knowledge check

1. What is Git?
2. What does GitHub add to Git?
3. What does clone do?
4. What does fetch do?
5. Why use feature branches?
6. What is a Pull Request?
7. Why keep PRs focused?
8. What are Issues used for?
9. What is GitHub Actions?
10. Why should secrets never be committed?
11. What does push do?
12. What should you inspect first after a CI failure?

### Answers

1. Distributed version control.
2. Hosting and collaboration capabilities around Git.
3. Creates a local copy of a remote repository.
4. Downloads remote history/references without automatically integrating them.
5. To isolate changes and protect the main branch.
6. A request to review and integrate changes.
7. They are easier to review, test and troubleshoot.
8. To track bugs, features, tasks and follow-ups.
9. GitHub's automation platform for CI/CD workflows.
10. They can expose credentials and compromise systems.
11. Sends local commits to a remote.
12. The first meaningful error in the workflow log.

## 14. Day 5 checklist

- [ ] Repository created
- [ ] Local repository pushed
- [ ] Feature branch created
- [ ] Pull Request opened
- [ ] Code reviewed
- [ ] Issue created
- [ ] Project workflow understood
- [ ] CI workflow created
- [ ] Authentication troubleshooting practiced
- [ ] Secret-handling rules understood

**FOMA — Foundation of Mastering Automation**  
Learn • Practice • Build • Advance  
https://foma.life
