#include "quat_norm_c.h"
#include "quat_norm.hpp"

/* C shim implementation - bridges C interface to C++ class */

QuatNormAlgorithm* QuatNormAlgorithm_create(void) {
    return reinterpret_cast<QuatNormAlgorithm*>(new QuatNorm());
}

void QuatNormAlgorithm_destroy(QuatNormAlgorithm* self) {
    if (self != nullptr) {
        delete reinterpret_cast<QuatNorm*>(self);
    }
}

QuatResult_C QuatNormAlgorithm_normalize(QuatNormAlgorithm* self, const Quaternion_C* input) {
    QuatResult_C result_c;
    
    if (self == nullptr || input == nullptr) {
        // Return invalid result on null pointers
        result_c.valid = false;
        result_c.magnitude = 0.0f;
        result_c.q_out[0] = 1.0f; // Identity quaternion
        result_c.q_out[1] = 0.0f;
        result_c.q_out[2] = 0.0f;
        result_c.q_out[3] = 0.0f;
        return result_c;
    }
    
    // Call C++ algorithm
    QuatNorm* algorithm = reinterpret_cast<QuatNorm*>(self);
    QuatResult cpp_result = algorithm->normalize(input->q);
    
    // Convert C++ result to C struct
    result_c.valid = cpp_result.valid;
    result_c.magnitude = cpp_result.magnitude;
    for (int i = 0; i < 4; ++i) {
        result_c.q_out[i] = cpp_result.q_out[i];
    }
    
    return result_c;
}