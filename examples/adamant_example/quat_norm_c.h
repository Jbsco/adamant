#ifndef QUAT_NORM_C_H
#define QUAT_NORM_C_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/* Opaque handle for C++ QuatNorm class */
typedef struct QuatNormAlgorithm QuatNormAlgorithm;

/* POD C struct for quaternion result */
typedef struct {
    float q_out[4];     /* Normalized quaternion [w, x, y, z] */
    float magnitude;    /* Original magnitude */
    bool valid;         /* True if normalization successful */
} QuatResult_C;

/* POD C struct for input quaternion */
typedef struct {
    float q[4];         /* Input quaternion [w, x, y, z] */
} Quaternion_C;

/* Algorithm lifecycle */
QuatNormAlgorithm* QuatNormAlgorithm_create(void);
void QuatNormAlgorithm_destroy(QuatNormAlgorithm* self);

/* Core algorithm function */
QuatResult_C QuatNormAlgorithm_normalize(QuatNormAlgorithm* self, const Quaternion_C* input);

#ifdef __cplusplus
}
#endif

#endif /* QUAT_NORM_C_H */