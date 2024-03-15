/// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
/// `parent` must not be modified if this is to be returned.
/// This will be noted in the runtime logs
#define COMPONENT_INCOMPATIBLE 1
/// Returned in PostTransfer to prevent transfer, similar to `COMPONENT_INCOMPATIBLE`
#define COMPONENT_NOTRANSFER 2

/// Return value to cancel attaching
#define ELEMENT_INCOMPATIBLE 1

// /datum/element flags
/// Causes the detach proc to be called when the host object is being deleted.
/// Should only be used if you need to perform cleanup not related to the host object.
/// You do not need this if you are only unregistering signals, for instance.
/// You would need it if you are doing something like removing the target from a processing list.
#define ELEMENT_DETACH_ON_HOST_DESTROY (1 << 0)
/**
 * Only elements created with the same arguments given after `argument_hash_start_idx` share an element instance
 * The arguments are the same when the text and number values are the same and all other values have the same ref
 */
#define ELEMENT_BESPOKE (1 << 1)
/// Causes all detach arguments to be passed to detach instead of only being used to identify the element
/// When this is used your Detach proc should have the same signature as your Attach proc
#define ELEMENT_COMPLEX_DETACH (1 << 2)

// How multiple components of the exact same type are handled in the same datum
/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER 0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED 1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE 2
/**
 * Component uses source tracking to manage adding and removal logic.
 * Add a source/spawn to/the component by using AddComponentFrom(source, component_type, args...)
 * Only the first args will be respected, and you should instead handle most of your logic in the on_source_added proc.
 * Removing the last source will automatically remove the component from the parent.
 */
#define COMPONENT_DUPE_SOURCES 3
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4
/// each component of the same type is consulted as to whether the duplicate should be allowed
#define COMPONENT_DUPE_SELECTIVE 5

//Redirection component init flags
#define REDIRECT_TRANSFER_WITH_TURF 1
