# Workflow (`symfony/workflow`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Workflow or state machine**: A workflow (`type: workflow`) lets an object be in several places at the same time. A state machine (`type: state_machine`) holds exactly one place. A workflow transition needs all its `from` places; a configured state machine transition needs one of them. If you omit `type`, the type is `state_machine`. Entry point: `framework.workflows.<name>.type`.
- **Definition**: A definition holds the places, the transitions and the initial marking. If you omit `places`, the component takes them from the transitions. If you omit `initial_marking`, the first place is the initial place. Entry points: `framework.workflows.<name>.places`, `transitions` and `initial_marking`; `DefinitionBuilder` for a standalone definition.
- **Check and apply**: `can()` tells if a transition is possible now. `apply()` moves the object and returns the new `Marking`. `getEnabledTransitions()` and `getEnabledTransition()` return the possible transitions. If a guard or the marking blocks the transition, `apply()` throws `NotEnabledTransitionException`, and its `getTransitionBlockerList()` returns the reasons. If the transition name is unknown, `apply()` throws `UndefinedTransitionException`. Both are subclasses of `Symfony\Component\Workflow\Exception\LogicException`. Entry point: `Symfony\Component\Workflow\WorkflowInterface`.
- **Marking store**: `MethodMarkingStore` reads `get<Property>()` and writes `set<Property>($places, array $context = [])`, or it uses a public property. The default property name is `marking`. A state machine stores a string. A workflow stores an array of place names and token counts, for example `['draft' => 1]`. If you store a workflow marking with Doctrine, use a `json` column, not `simple_array`. If the stored marking is empty, `getMarking()` writes the initial places to the object. For another storage, implement `MarkingStoreInterface`. Set its service ID in `marking_store.service`. Entry point: `framework.workflows.<name>.marking_store`.
- **Enums**: Places, `initial_marking`, `from` and `to` accept backed enum cases, for example `!php/enum App\Enum\Status::Draft` in YAML. `places: !php/enum App\Enum\Status` adds all cases. `places: 'App\Enum\Status::*'` adds the constants or cases that match a glob pattern. `MethodMarkingStore` converts a `BackedEnum`-typed property of a single-state store. If the marking property is an enum, use `type: state_machine`.
- **Weighted transitions**: In a workflow, an arc can take or give several tokens, for example `from: [{ place: leg_created, weight: 4 }]`. The marking then counts the tokens in each place (`Marking::getTokenCount()`). The state machine validator rejects a weight above 1. Entry points: the arc keys `place` and `weight`; `Symfony\Component\Workflow\Arc`.
- **Events**: `apply()` dispatches `workflow.guard`, `workflow.leave`, `workflow.transition`, `workflow.enter`, `workflow.entered`, `workflow.completed` and `workflow.announce`, in this order. Each event has three names: `workflow.<event>`, `workflow.<name>.<event>` and `workflow.<name>.<event>.<place or transition>`. The static `getName()` method of each event class builds a name from two arguments, for example `LeaveEvent::getName('blog_publishing', null)`. A `TransitionEvent` listener can change the context with `setContext()`, and `Marking::getContext()` returns the final context. A standalone `Workflow` without an event dispatcher dispatches no events and runs no guards. Entry points: `Symfony\Component\Workflow\Event\*`, `WorkflowEvents`.
- **Listener attributes**: `#[AsGuardListener]`, `#[AsLeaveListener]`, `#[AsTransitionListener]`, `#[AsEnterListener]`, `#[AsEnteredListener]`, `#[AsCompletedListener]` and `#[AsAnnounceListener]` register a method or a class as a listener. They take the `workflow` name and a `transition`, or a `place` for leave, enter and entered. They extend `AsEventListener`, so autoconfiguration registers them. Example: `#[AsCompletedListener('blog_publishing', 'publish')]`.
- **Guards**: The `guard` option of a transition takes an ExpressionLanguage expression, for example `is_granted('ROLE_REVIEWER') and subject.isRejectable()`. Guard expressions can call `is_granted()`, `is_authenticated()`, `is_fully_authenticated()`, `is_remember_me()` and `is_valid()`. Write each function with parentheses. To validate the object, write `is_valid(subject)`. Guard expressions can read the variables `subject`, `user`, `token` and `role_names`. Guard expressions need `symfony/expression-language` and SecurityBundle. For a rule in PHP code, call `GuardEvent::setBlocked(true, $message)` or `addTransitionBlocker()` in a guard listener.
- **Event selection**: `events_to_dispatch` limits the events that a workflow dispatches, and an empty array dispatches none. The component always dispatches guard events. A context key such as `Workflow::DISABLE_ANNOUNCE_EVENT => true` disables one event for one `apply()` call. The announce event runs all guards again; if the guards are slow, disable it.
- **Metadata**: The `metadata` option stores data on the workflow, on each place and on each transition. Read it with `getMetadataStore()->getMetadata($key, $placeOrTransition)`, with `Event::getMetadata()` in a listener, or with `workflow_metadata()` in Twig. The dumpers read the `label`, `description`, `bg_color`, `color` and `arrow_color` keys.
- **Twig functions**: `workflow_can()`, `workflow_transitions()`, `workflow_transition()`, `workflow_has_marked_place()`, `workflow_marked_places()`, `workflow_transition_blockers()` and `workflow_metadata()` read the workflow state of an object. They find the workflow through `supports` (class names) or `support_strategy` (a service ID), and the configuration requires one of the two. A `support_strategy` service implements `Symfony\Component\Workflow\SupportStrategy\WorkflowSupportStrategyInterface`. If several workflows support a class, pass the workflow name as the last argument.
- **Definition validation**: The container build checks each configured definition with `WorkflowValidator` or `StateMachineValidator`. For extra checks, list classes in `definition_validators`. Each class implements `DefinitionValidatorInterface` and has no required constructor arguments.
- **Audit trail**: `audit_trail: { enabled: true }` logs each leave, transition and enter at the info level, on the `workflow` Monolog channel.
- **Dump and profiler**: `workflow:dump <name>` prints the definition as DOT (the default), PlantUML (`--dump-format=puml`) or Mermaid (`--dump-format=mermaid`). Place names after the workflow name highlight these places. If the profiler is enabled, the web profiler shows a workflow panel with a Mermaid diagram and the listeners. In debug mode, the panel also shows the workflow calls.

## Entry points

- `Symfony\Component\Workflow\WorkflowInterface`: autowire it with `#[Target('blog_publishing')]` (`Symfony\Component\DependencyInjection\Attribute\Target`). Symfony 8.1 deprecates the match on the argument name alone (`$blogPublishingWorkflow`, or `$pullRequestStateMachine` for a state machine).
- `#[AutowireLocator('workflow', 'name')]` (`Symfony\Component\DependencyInjection\Attribute\AutowireLocator`) on a `Symfony\Component\DependencyInjection\ServiceLocator` argument: all workflows, keyed by name. The service tags are `workflow`, `workflow.workflow` and `workflow.state_machine`.
- Service IDs: `workflow.<name>` and `state_machine.<name>`. These services are private. Inject them. Do not get them from the container.
- `Symfony\Component\Workflow\Registry` (service `workflow.registry`): `get($subject, $workflowName)` finds the workflow that supports an object. The Twig functions use it. The docs do not describe it.
- Config: `framework.workflows` with `type`, `supports`, `support_strategy`, `initial_marking`, `places`, `transitions` (`from`, `to`, `guard`, `metadata`; arc keys `place` and `weight`), `marking_store` (`type`, `property`, `service`), `audit_trail`, `events_to_dispatch`, `definition_validators` and `metadata`. Show the tree with `php bin/console config:dump-reference framework workflows`.
- Attributes: `Symfony\Component\Workflow\Attribute\AsGuardListener`, `AsLeaveListener`, `AsTransitionListener`, `AsEnterListener`, `AsEnteredListener`, `AsCompletedListener`, `AsAnnounceListener`.
- Events: `Symfony\Component\Workflow\Event\GuardEvent`, `LeaveEvent`, `TransitionEvent`, `EnterEvent`, `EnteredEvent`, `CompletedEvent`, `AnnounceEvent` (base class `Event`); event names in `Symfony\Component\Workflow\WorkflowEvents`.
- Blockers and errors: `Symfony\Component\Workflow\TransitionBlocker`, `TransitionBlockerList`, `Exception\NotEnabledTransitionException`, `Exception\UndefinedTransitionException`, `Exception\LogicException`.
- Marking: `Symfony\Component\Workflow\Marking`, `MarkingStore\MarkingStoreInterface`, `MarkingStore\MethodMarkingStore`.
- Without FrameworkBundle: `Symfony\Component\Workflow\DefinitionBuilder`, `Definition`, `Transition`, `Arc`, `Workflow`, `StateMachine`.
- Validation: `Symfony\Component\Workflow\Validator\DefinitionValidatorInterface`, `WorkflowValidator`, `StateMachineValidator`, `Exception\InvalidDefinitionException`.
- Metadata: `Symfony\Component\Workflow\Metadata\MetadataStoreInterface`, from `getMetadataStore()`.
- Console: `workflow:dump <name> [<place>...]` with `--dump-format=dot|puml|mermaid`, `--with-metadata` (DOT only), `--with-listeners` (DOT output of a `workflow` type only) and `--label`; `debug:autowiring workflow` lists the workflow services.
- Twig: `workflow_can()`, `workflow_transitions()`, `workflow_transition()`, `workflow_has_marked_place()`, `workflow_marked_places()`, `workflow_transition_blockers()`, `workflow_metadata()`, from `Symfony\Bridge\Twig\Extension\WorkflowExtension`.
- Standalone dumpers: `Symfony\Component\Workflow\Dumper\GraphvizDumper`, `StateMachineGraphvizDumper`, `PlantUmlDumper` (needs `PlantUmlDumper::WORKFLOW_TRANSITION` or `STATEMACHINE_TRANSITION`), `MermaidDumper` (needs `MermaidDumper::TRANSITION_TYPE_WORKFLOW` or `TRANSITION_TYPE_STATEMACHINE`).

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): reads `framework.workflows`, registers one service per workflow, and adds the `workflow:dump` command and the profiler data collector.
- [EventDispatcher](../packages/event-dispatcher.md): dispatches the workflow events, and the workflow listener attributes extend its `AsEventListener`.
- [ExpressionLanguage](../packages/expression-language.md): evaluates the `guard` expressions of transitions.
- [Security](../packages/security-bundle.md): provides the services behind `is_granted()` and the other guard functions. If a transition has a `guard` and SecurityBundle is missing, the container build fails.
- [Validator](../packages/validator.md): checks the constraints of the subject in the `is_valid(subject)` guard function; it is not related to `definition_validators`.
- [Twig Bridge](../packages/twig-bridge.md): defines the `workflow_*()` Twig functions in `WorkflowExtension`.
- [TwigBundle](../packages/twig-bundle.md): registers `WorkflowExtension` when the workflow registry exists.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target]` injects one workflow, and `#[AutowireLocator]` injects all workflows.
- [MonologBundle](../packages/monolog-bundle.md): sends the audit trail logs to the `workflow` channel.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): shows the workflow panel with a Mermaid diagram, the listeners and, in debug mode, the workflow calls.
- [Form](../packages/form.md): for a multi-step form wizard, use the Form flow (`AbstractFlowType`); for the status of a domain object, use Workflow.

## Changed in 8.0/8.1

- 8.1: `workflow:dump --with-listeners` adds the transition listeners and guard expressions to the DOT output of a workflow.
- 8.0: `Event::getWorkflow()` is removed. Inject the workflow with `#[Target('my_workflow')] WorkflowInterface $workflow`, or use `#[AutowireLocator('workflow', 'name')]` with `$event->getWorkflowName()`.
- 8.0: `WorkflowInterface` declares `getEnabledTransition()`. Add this method to custom implementations.
- 8.0: `Marking::mark()` and `unmark()` take `$nbToken`, and `Transition::getFroms()` and `getTos()` take `$asArc`. Update subclasses that override these methods.
- 8.0: The `WorkflowDumpCommand` class moved from FrameworkBundle to `Symfony\Component\Workflow\Command\WorkflowDumpCommand`. The `workflow:dump` command does not change.
- 7.4/8.0: Weighted transitions (`Arc`, `weight`), `BackedEnum` support in `MethodMarkingStore` and places from glob patterns of constants or enum cases are new.
- 8.0: The fluent PHP config format (`static function (FrameworkConfig $framework)`) is removed. Return `App::config([...])` arrays. The weighted transition PHP example in the docs uses the old format.

## Docs

- https://symfony.com/doc/current/workflow.html
- https://symfony.com/doc/current/workflow/workflow-and-state-machine.html
- https://symfony.com/doc/current/workflow/dumping-workflows.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/attributes.html
