//
//  TabBarTransition.swift
//  XCoordinator
//
//  Created by Paul Kraft on 27.07.18.
//  Copyright © 2018 QuickBird Studios. All rights reserved.
//

import UIKit

/// TabBarTransition offers transitions that can be used
/// with a `UITabBarController` rootViewController.
public typealias TabBarTransition = Transition<UITabBarController>

extension Transition where RootViewController: UITabBarController {

    ///
    /// Transition to set the tabs of the rootViewController with an optional custom animation.
    ///
    /// - Note:
    ///     Only the presentation animation of the Animation object is used.
    ///
    /// - Parameters:
    ///     - presentables:
    ///         The tabs to be set are defined by the presentables' viewControllers.
    ///     - animation:
    ///         The animation to be used. If you specify `nil` here, the default animation by UIKit is used.
    ///
    public static func set(_ presentables: [any Presentable], animation: Animation? = nil) -> Transition {
        Transition {
            SetTabs(animation: animation) {
                presentables
            }
        }
    }

    ///
    /// Transition to select a tab with an optional custom animation.
    ///
    /// - Note:
    ///     Only the presentation animation of the Animation object is used.
    ///
    /// - Parameters:
    ///     - presentable:
    ///         The tab to be selected is the presentable's viewController. Make sure that this is one of the
    ///         previously specified tabs of the rootViewController.
    ///     - animation:
    ///         The animation to be used. If you specify `nil` here, the default animation by UIKit is used.
    ///
    public static func select(_ presentable: any Presentable, animation: Animation? = nil) -> Transition {
        Transition {
            SelectTab(animation: animation) {
                presentable
            }
        }
    }

    ///
    /// Transition to select a tab with an optional custom animation.
    ///
    /// - Note:
    ///     Only the presentation animation of the Animation object is used.
    ///
    /// - Parameters:
    ///     - index:
    ///         The index of the tab to be selected. Make sure that there is a tab at the specified index.
    ///     - animation:
    ///         The animation to be used. If you specify `nil` here, the default animation by UIKit is used.
    ///
    public static func select(index: Int, animation: Animation? = nil) -> Transition {
        Transition {
            SelectTab(at: index, animation: animation)
        }
    }

}
