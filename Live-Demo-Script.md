We talked about why Shore, let's see how to Shore.

I'm going to show you how we work with Shore in Autodesk.
Hopefully this glimpse into the workflow we have will help you understand the project and it's intentions.

Let's set the stage here.
I'm a new developer in the team. I just learned about Shore.

The pipeline i'm working with is a deployment pipeline that deploys a KubeJob with that produces an echo.

Riveting, right?

Like I said, I'm a new developer in the team & never saw the project before.

Luckily with Shore, I know exactly where to start.

A Shore project always defines the pipeline in `main.pipeline.jsonnet`.

Let's see glance on the code, just to see it exists.

We'll skip the details for now, and start working.

We got our first bug, it states:

> ISSUE-256: sometimes a number parameter will fail the pipeline
> Example:

```yaml
parameters:
    echo1: 1
```

Luckily for us, the bug report contains the exact parameters needed to re-produce the error.

But wait, I can't just work on the pipeline production pipeline right?
There may be deployments running at the same time. We don't want to cause a deployment outage.

To solve for that let's look at the `render.yml` file.
It contains the `application` & `pipeline` properties.

Let's look at the `main.pipeline.jsonnet` now.

We will focus on the `main` function.
It takes a `params` argument.
These params are passed to the rendering engine from `render.yml`.

By changing the `pipeline` property, I can create a new pipeline, leaving the old pipeline intact.

I'll use this to create my test pipeline.

Let's give it the name `dev-shoredemo-pipeline-I256`.

Finally we use the `shore save` command to store this pipeline in Spinnaker.

> Just double check it exists, great!

Now we're free to break stuff without pulling production builds down with us.

Let's try reproducing the bug.

We need to execute the pipeline to reproduce the bug.

Now some would just click the UI, but I think we are engineers that love the command line.

Using the magic of copy/paste we put the parameters into our `exec.yml` file.

`exec.yml` parameters are used to trigger the pipeline with a set of execution parameters.

This is very useful for quick debug cycles.

Let's run `shore exec` and wait for eventual failure.

We see that the stage fails with:

> Create failed: Error from server (BadRequest): error when creating "STDIN": Job in version "v1" cannot be handled as a Job: json: cannot unmarshal number into Go struct field

This is where your Jedi training finally pays off. This looks like a classic type error!

Let's fix that.

First let's find the cause.

We can just look for the first reference for Kubernetes here.

This will lead us to the KubeJob instantiation.
Looking closer I can see `spel.parameter`.

For a bit of context, Spinnaker embeds an expression language called SpEL. Acronym for Spring Expression Language.
The SpEL expression line basically says, take the parameter from the execution, and put it in the KubeJob manifest.

Now during Jedi training, I learned that many object in SpEL have a `toString` method.
Let's see if that fixes the issue.

Lastly, we `shore save` to apply our change, and `shore exec` to try and trigger the bug again.

Looks like we fixed our first bug in record time.

But we our work isn't done.

If we open a Pull Request now with this fix, the lead developer won't review it.
They will just comment "TESTS?!?!".

I know.. It hurts, but they are correct. How do I know this fix will stay, you know, fixed?

That's where Shore comes in again to save the day.

We've been ignoring a very interesting file called `E2E.yml`.

Let's click on it.

`E2E.yml` contains our tests.

It seems that we already have a test that calls the pipeline with a parameter of type string.

Let's use the same configuration, but set a parameter of type int.

Using `shore test-remote` we can invoke the test suite.

We also use the `-c` flag to enable to run concurrently.

Seems like we can open the PR now. And deploy to production.

I'll let you imagine the conversation, while we keep talking about Shore :)
