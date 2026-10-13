# Workflow (`symfony/workflow`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an order, an article or an approval request has a status that may change only through allowed steps. It defines the statuses and the allowed changes once, as a workflow or a state machine. It checks, applies, guards and logs each change. For a multi-step form wizard, see [Form](form.md).

**Details:** [../details/workflow.md](../details/workflow.md)

## Why it exists

Applications often store a status on an object and change it in controllers, commands and listeners. Without one central definition, the allowed changes, the access rules and the side effects spread through the code. The package defines the statuses and the allowed changes once, in configuration or in PHP code. It then enforces them on each change.

## When to use it

- Enforce the allowed status changes of an object, for example draft to review to published.
- Block a status change with a business rule, a role check or a validation check.
- Show in an HTML template only the actions that the current user can apply to an object.
- Run code, for example send an email, when an object enters a status or completes a change.
- Track parallel steps of one object, for example several reviews that must all finish before the next step.
- Require a number of parts before a step, for example 4 legs before the table assembly.
- Record an audit log of each status change.
- Draw a diagram of a process for documentation or a review.
- Define the statuses and the allowed changes in plain PHP code, without the full framework.

## Use it instead of

- `if ($post->getStatus() === 'draft') { $post->setStatus('reviewed'); }` in each controller -> `$workflow->apply($post, 'to_review')` with the transitions in `framework.workflows`.
- A hand-written map such as `const ALLOWED = ['draft' => ['reviewed']]` plus `in_array()` checks -> `WorkflowInterface::can()` and `getEnabledTransitions()`.
- `if (!$this->isGranted('ROLE_REVIEWER')) { throw $this->createAccessDeniedException(); }` before a status change -> a `guard: "is_granted('ROLE_REVIEWER')"` expression on the transition, or an `#[AsGuardListener]` method.
- `{% if post.status == 'reviewed' %}` around action buttons in Twig -> `{% if workflow_can(post, 'publish') %}` or `{% for transition in workflow_transitions(post) %}`.
- `$mailer->send($email)` after each `setStatus()` call -> a listener method with `#[AsCompletedListener('blog_publishing', 'publish')]`.
- `$logger->info('Status changed ...')` at each place that changes a status -> `audit_trail: { enabled: true }`.
- Counters and flags such as `$legsBuilt++` and `if ($legsBuilt === 4 && $topBuilt)` -> weighted transitions (`weight`, `Arc`) in a workflow.
- Error strings that a controller builds when it refuses a change -> `TransitionBlocker` messages from `buildTransitionBlockerList()` or `workflow_transition_blockers()`.
- A hand-drawn state diagram -> `php bin/console workflow:dump blog_publishing | dot -Tsvg -o graph.svg`.
