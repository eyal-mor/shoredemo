Explicit!
Focus on moves between screens.
Describe in excruciating details what is going on.

We talked about why Shore, let's see how to Shore.

I'm going to show you how we work with Shore in Autodesk.
Hopefully this glimpse into the workflow we have will help you understand the project and it's intentions.

Let's set the stage here.
I'm a new developer in the team. I just learned about Shore, and I need to fix a bug.

The pipeline i'm working with is

Do you know the feeling going into a project and not knowing where to start looking?
What's the first file I click into?

Shore takes care of that problem, by setting a common project structure. Similar to other Frameworks we know and love.

A shore project always starts with the following files:

```sh
|- main.pipeline.jsonnet
```

I mentioned there is a bug.
The bug states:

> ISSUE-256: sometimes a number parameter will fail the pipeline
> Example:

```yaml
parameters:
    echo1: 1
```

Very luck for us, we have how to reproduce the issue.

The main function takes a `params` argument.
These params are passed to the rendering engine from `render.yml`.

I'll use this to create my test pipeline.

Changing the value `shoredemo-pipeline` to `shoredemo-pipeline`.

Great, now i'm free to break stuff without pulling production builds down with me.

Let's try reproducing the bug.

Let's copy/paste these parameters into our `exec.yml` file.

And run `shore exec`.

We see that the stage fails with:

> Create failed: Error from server (BadRequest): error when creating "STDIN": Job in version "v1" cannot be handled as a Job: json: cannot unmarshal number into Go struct field

This is where your Jedi training finally pays off. We have type error!

Let's fix that.
With Jsonnet let's apply a quick fix to see if we can Solve out issue with a small magical `toString`.

`shore save && shore exec`, and boom, crisis averted!

But what actually prevents me from breaking this patch in the future?
We need to test the pipeline.

Well, that's where `E2E.yml` plays in.
