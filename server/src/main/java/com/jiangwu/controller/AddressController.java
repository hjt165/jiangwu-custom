package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.request.CreateAddressRequest;
import com.jiangwu.dto.response.AddressResponse;
import com.jiangwu.service.AddressService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 收货地址控制器
 */
@RestController
@RequestMapping("/address")
@RequiredArgsConstructor
public class AddressController {

    private final AddressService addressService;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 获取地址列表
     */
    @GetMapping("/list")
    public Result<List<AddressResponse>> getAddresses(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(addressService.getAddresses(userId));
    }

    /**
     * 获取单个地址
     */
    @GetMapping("/{id}")
    public Result<AddressResponse> getAddress(HttpServletRequest request, @PathVariable Long id) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(addressService.getAddress(userId, id));
    }

    /**
     * 新增地址
     */
    @PostMapping("/create")
    public Result<AddressResponse> createAddress(HttpServletRequest request,
                                                  @Valid @RequestBody CreateAddressRequest addressRequest) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(addressService.createAddress(userId, addressRequest));
    }

    /**
     * 更新地址
     */
    @PutMapping("/{id}")
    public Result<AddressResponse> updateAddress(HttpServletRequest request,
                                                  @PathVariable Long id,
                                                  @Valid @RequestBody CreateAddressRequest addressRequest) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(addressService.updateAddress(userId, id, addressRequest));
    }

    /**
     * 删除地址
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteAddress(HttpServletRequest request, @PathVariable Long id) {
        Long userId = currentUserUtil.extractUserId(request);
        addressService.deleteAddress(userId, id);
        return Result.success(null);
    }

    /**
     * 设为默认地址
     */
    @PutMapping("/{id}/default")
    public Result<Void> setDefault(HttpServletRequest request, @PathVariable Long id) {
        Long userId = currentUserUtil.extractUserId(request);
        addressService.setDefault(userId, id);
        return Result.success(null);
    }
}
