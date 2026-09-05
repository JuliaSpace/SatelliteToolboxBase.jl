## Description #############################################################################
#
# This file defines types for Jacobian methods.
#
############################################################################################

export AbstractJacobianMethod, FiniteDiffJacobian, ForwardDiffJacobian

"""
    abstract type AbstractJacobianMethod

Abstract type for Jacobian methods.
"""
abstract type AbstractJacobianMethod end

"""
    struct FiniteDiffJacobian <: AbstractJacobianMethod

Select the finite-difference Jacobian.
"""
struct FiniteDiffJacobian <: AbstractJacobianMethod end

"""
    struct ForwardDiffJacobian <: AbstractJacobianMethod

Select the ForwardDiff automatic-differentiation Jacobian.
"""
struct ForwardDiffJacobian <: AbstractJacobianMethod end
